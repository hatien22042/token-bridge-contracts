/*
 * Copyright 2020, Offchain Labs, Inc.
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

package arbbridge

import (
	"context"

	"github.com/offchainlabs/arbitrum/packages/arb-util/common"
	"github.com/offchainlabs/arbitrum/packages/arb-validator-core/valprotocol"
)

type ArbRollupWatcher interface {
	ContractWatcher

	GetParams(ctx context.Context) (valprotocol.ChainParams, error)
	InboxAddress(ctx context.Context) (common.Address, error)
	GetCreationInfo(ctx context.Context) (common.Hash, *common.BlockId, common.Hash, error)
	GetVersion(ctx context.Context) (string, error)
}

type GlobalInboxWatcher interface {
	ContractWatcher
}
