/* Generated by ts-generator ver. 0.0.8 */
/* tslint:disable */

import { Contract, ContractFactory, Signer } from 'ethers'
import { Provider } from 'ethers/providers'
import { UnsignedTransaction } from 'ethers/utils/transaction'

import { ArbFactory } from './ArbFactory'

export class ArbFactoryFactory extends ContractFactory {
  constructor(signer?: Signer) {
    super(_abi, _bytecode, signer)
  }

  deploy(
    _rollupTemplate: string,
    _globalInboxAddress: string,
    _challengeFactoryAddress: string
  ): Promise<ArbFactory> {
    return super.deploy(
      _rollupTemplate,
      _globalInboxAddress,
      _challengeFactoryAddress
    ) as Promise<ArbFactory>
  }
  getDeployTransaction(
    _rollupTemplate: string,
    _globalInboxAddress: string,
    _challengeFactoryAddress: string
  ): UnsignedTransaction {
    return super.getDeployTransaction(
      _rollupTemplate,
      _globalInboxAddress,
      _challengeFactoryAddress
    )
  }
  attach(address: string): ArbFactory {
    return super.attach(address) as ArbFactory
  }
  connect(signer: Signer): ArbFactoryFactory {
    return super.connect(signer) as ArbFactoryFactory
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ArbFactory {
    return new Contract(address, _abi, signerOrProvider) as ArbFactory
  }
}

const _abi = [
  {
    inputs: [
      {
        internalType: 'address',
        name: '_rollupTemplate',
        type: 'address',
      },
      {
        internalType: 'address',
        name: '_globalInboxAddress',
        type: 'address',
      },
      {
        internalType: 'address',
        name: '_challengeFactoryAddress',
        type: 'address',
      },
    ],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'constructor',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: 'address',
        name: 'vmAddress',
        type: 'address',
      },
    ],
    name: 'RollupCreated',
    type: 'event',
  },
  {
    constant: true,
    inputs: [],
    name: 'challengeFactoryAddress',
    outputs: [
      {
        internalType: 'address',
        name: '',
        type: 'address',
      },
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function',
  },
  {
    constant: true,
    inputs: [],
    name: 'globalInboxAddress',
    outputs: [
      {
        internalType: 'address',
        name: '',
        type: 'address',
      },
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function',
  },
  {
    constant: true,
    inputs: [],
    name: 'rollupTemplate',
    outputs: [
      {
        internalType: 'address',
        name: '',
        type: 'address',
      },
    ],
    payable: false,
    stateMutability: 'view',
    type: 'function',
  },
  {
    constant: false,
    inputs: [
      {
        internalType: 'bytes32',
        name: '_vmState',
        type: 'bytes32',
      },
      {
        internalType: 'uint128',
        name: '_gracePeriodTicks',
        type: 'uint128',
      },
      {
        internalType: 'uint128',
        name: '_arbGasSpeedLimitPerTick',
        type: 'uint128',
      },
      {
        internalType: 'uint64',
        name: '_maxExecutionSteps',
        type: 'uint64',
      },
      {
        internalType: 'uint64[2]',
        name: '_maxTimeBoundsWidth',
        type: 'uint64[2]',
      },
      {
        internalType: 'uint128',
        name: '_stakeRequirement',
        type: 'uint128',
      },
      {
        internalType: 'address payable',
        name: '_owner',
        type: 'address',
      },
    ],
    name: 'createRollup',
    outputs: [],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'function',
  },
]

const _bytecode =
  '0x608060405234801561001057600080fd5b5060405161051e38038061051e8339818101604052606081101561003357600080fd5b5080516020820151604090920151600080546001600160a01b039384166001600160a01b031991821617909155600180549484169482169490941790935560028054929091169190921617905561048f8061008f6000396000f3fe608060405234801561001057600080fd5b506004361061004c5760003560e01c8063582923c71461005157806362e3c0b1146100755780638689d9961461007d578063b10c5f8414610085575b600080fd5b6100596100e9565b604080516001600160a01b039092168252519081900360200190f35b6100596100f8565b610059610107565b6100e7600480360361010081101561009c57600080fd5b5080359060208101356001600160801b03908116916040810135821691606082013567ffffffffffffffff1691608081019160c0820135169060e001356001600160a01b0316610116565b005b6001546001600160a01b031681565b6002546001600160a01b031681565b6000546001600160a01b031681565b6000805461012c906001600160a01b03166102a1565b60025460015460408051638e0f716760e01b8152600481018d81526001600160801b03808e1660248401528c16604483015267ffffffffffffffff8b1660648301529495506001600160a01b0380871695638e0f7167958f958f958f958f958f958f958f95908316949216929091608490910190879080828437600081840152601f19601f820116905080830192505050856001600160801b03166001600160801b03168152602001846001600160a01b03166001600160a01b03168152602001836001600160a01b03166001600160a01b03168152602001826001600160a01b03166001600160a01b031681526020019950505050505050505050600060405180830381600087803b15801561024257600080fd5b505af1158015610256573d6000803e3d6000fd5b5050604080516001600160a01b038516815290517f84c162f1396badc29f9c932c79d7495db699b615e2c0da163ae26bd5dbe71d7c9350908190036020019150a15050505050505050565b60006060604051806020016102b5906103be565b601f1982820381018352601f9091011660408181526001600160a01b038616602083810191909152815180840382018152828401909252835191926060019182918501908083835b6020831061031c5780518252601f1990920191602091820191016102fd565b51815160209384036101000a600019018019909216911617905285519190930192850191508083835b602083106103645780518252601f199092019160209182019101610345565b6001836020036101000a038019825116818451168082178552505050505050905001925050506040516020818303038152906040529050806020018151808234f09350836103b6573d6000803e3d6000fd5b505050919050565b6090806103cb8339019056fe6080604052348015600f57600080fd5b506040516090380380609083398181016040526020811015602f57600080fd5b50516040805169363d3d373d3d3d363d7360b01b6020828101919091526001600160601b0319606085901b16602a8301526e5af43d82803e903d91602b57fd5bf360881b603e8301528251602d81840381018252604d9093019093528201f3fea265627a7a72315820072c341a7bef714266abf10f69504685c69996cdb1bb1fa9f03e2bd7353d31dc64736f6c634300050f0032'
