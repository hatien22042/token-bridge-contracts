/*
 * Copyright 2019, Offchain Labs, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity ^0.5.3;

import "./VM.sol";
import "./Disputable.sol";
import "./IArbBase.sol";

import "../IGlobalPendingInbox.sol";

import "../challenge/IChallengeFactory.sol";

import "../arch/Protocol.sol";
import "../arch/Value.sol";


contract ArbBase is IArbBase {
    using SafeMath for uint256;

    // fields:
        // beforeHash
        // beforeInbox
        // afterHash
        // messagesAccHash
        // logsAccHash

    event PendingDisputableAssertion (
        bytes32[5] fields,
        address asserter,
        uint64[2] timeBounds,
        uint32 numSteps,
        uint64 numGas,
        uint64 deadline
    );

    event ConfirmedDisputableAssertion(
        bytes32 newState,
        bytes32 logsAccHash
    );

    event ChallengeLaunched(
        address challengeContract,
        address challenger
    );

    address internal constant ETH_ADDRESS = address(0);

    IChallengeFactory public challengeFactory;
    IGlobalPendingInbox public globalInbox;

    VM.Data public vm;
    mapping(address => uint256) validatorBalances;

    address payable public exitAddress;
    address payable public terminateAddress;
    address payable public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only callable by owner");
        _;
    }

    function initialize(
        bytes32 _vmState,
        uint32 _gracePeriod,
        uint32 _maxExecutionSteps,
        uint128 _escrowRequired,
        address payable _owner,
        address _challengeFactoryAddress,
        address _globalInboxAddress
    )
        public
    {
        require(address(challengeFactory) == address(0), "VM already initialized");
        require(_challengeFactoryAddress != address(0), "Challenge factory address not set");

        globalInbox = IGlobalPendingInbox(_globalInboxAddress);
        challengeFactory = IChallengeFactory(_challengeFactoryAddress);

        globalInbox.registerForInbox();
        owner = _owner;

        // Machine state
        vm.machineHash = _vmState;
        vm.state = VM.State.Uninitialized;
        vm.inbox = Value.hashEmptyTuple();

        // Validator options
        vm.escrowRequired = _escrowRequired;
        vm.gracePeriod = _gracePeriod;
        vm.maxExecutionSteps = _maxExecutionSteps;
    }

    function currentDeposit(address validator) external view returns(uint256) {
        return validatorBalances[validator];
    }

    function escrowRequired() external view returns(uint256) {
        return vm.escrowRequired;
    }

    function getState() external view returns(VM.State) {
        return vm.state;
    }

    function activateVM() external onlyOwner {
        if (vm.state == VM.State.Uninitialized) {
            vm.state = VM.State.Waiting;
        }
    }

    function ownerShutdown() external onlyOwner {
        _shutdown();
    }

    function completeChallenge(address[2] calldata _players, uint128[2] calldata _rewards) external {
        require(
            msg.sender == address(vm.activeChallengeManager),
            "Only challenge manager can complete challenge"
        );

        vm.activeChallengeManager = address(0);
        validatorBalances[_players[0]] = validatorBalances[_players[0]].add(_rewards[0]);
        validatorBalances[_players[1]] = validatorBalances[_players[1]].add(_rewards[1]);
    }

    function pendingDisputableAssert(
        bytes32 _beforeHash,
        bytes32 _beforeInbox,
        bytes32 _afterHash,
        bool    _didInboxInsn,
        bytes32 _messagesAccHash,
        bytes32 _logsAccHash,
        uint32 _numSteps,
        uint64 _numGas,
        uint64[2] memory _timeBounds
    )
        public
    {
        require(
            vm.escrowRequired <= validatorBalances[msg.sender],
            "Validator does not have required escrow to assert"
        );
        validatorBalances[msg.sender] -= vm.escrowRequired;

        Disputable.pendingDisputableAssert(
            vm,
            _beforeHash,
            _beforeInbox,
            _afterHash,
            _didInboxInsn,
            _messagesAccHash,
            _logsAccHash,
            _numSteps,
            _numGas,
            _timeBounds
        );
    }

    function confirmDisputableAsserted(
        bytes32 _preconditionHash,
        bytes32 _afterHash,
        bool    _didInboxInsn,
        uint32 _numSteps,
        uint64 _numGas,
        bytes memory _messages,
        bytes32 _logsAccHash
    )
        public
    {
        Disputable.confirmDisputableAsserted(
            vm,
            _preconditionHash,
            _afterHash,
            _didInboxInsn,
            _numSteps,
            _numGas,
            _messages,
            _logsAccHash
        );

        validatorBalances[vm.asserter] = validatorBalances[vm.asserter].add(vm.escrowRequired);

        _completeAssertion(_messages);
    }

    function initiateChallenge(
        bytes32 _beforeHash,
        bytes32 _beforeInbox,
        uint64[2] memory _timeBounds,
        bytes32 _assertionHash
    )
        public
    {
        require(
            vm.escrowRequired <= validatorBalances[msg.sender],
            "Challenger did not have enough escrowed"
        );
        validatorBalances[msg.sender] -= vm.escrowRequired;

        Disputable.initiateChallenge(
            vm,
            _beforeHash,
            _beforeInbox,
            _timeBounds,
            _assertionHash
        );

        vm.activeChallengeManager = challengeFactory.createChallenge(
            [vm.asserter, msg.sender],
            [vm.escrowRequired, vm.escrowRequired],
            vm.gracePeriod,
            _beforeHash,
            _beforeInbox,
            _timeBounds,
            _assertionHash
        );

        emit ChallengeLaunched(vm.activeChallengeManager, msg.sender);
    }

    function _completeAssertion(bytes memory _messages) internal {
        bytes32 pending = globalInbox.pullPendingMessages();
        if (pending != Value.hashEmptyTuple()) {
            vm.inbox = Value.hashTuple([
                Value.newInt(1),
                Value.newHashOnly(vm.inbox),
                Value.newHashOnly(pending)
            ]);
        }

        globalInbox.sendMessages(_messages);
    }

    function _shutdown() private {
        // TODO: transfer all owned funds to halt address
        selfdestruct(owner);
    }
}
