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

#include <data_storage/checkpoint/machinestatesaver.hpp>

#include <avm_values/tuple.hpp>
#include <data_storage/checkpoint/checkpointutils.hpp>
#include <data_storage/storageresult.hpp>
#include <data_storage/transaction.hpp>

namespace {
rocksdb::Slice vecToSlice(const std::vector<unsigned char>& vec) {
    return {reinterpret_cast<const char*>(vec.data()), vec.size()};
}

std::vector<unsigned char> getHashKey(const value& val) {
    auto hash_key = hash_value(val);
    std::vector<unsigned char> hash_key_vector;
    marshal_uint256_t(hash_key, hash_key_vector);

    return hash_key_vector;
}

SaveResults saveTuple(Transaction& transaction, const Tuple& val) {
    auto hash_key = getHashKey(val);
    auto key = vecToSlice(hash_key);
    auto results = transaction.getData(key);

    auto incr_ref_count = results.status.ok() && results.reference_count > 0;

    if (incr_ref_count) {
        return transaction.incrementReference(key);
    } else {
        std::vector<unsigned char> value_vector;
        value_vector.push_back(TUPLE + val.tuple_size());

        for (uint64_t i = 0; i < val.tuple_size(); i++) {
            auto current_val = val.get_element(i);
            auto serialized_val =
                checkpoint::utils::serializeValue(current_val);

            value_vector.insert(value_vector.end(), serialized_val.begin(),
                                serialized_val.end());

            auto type = static_cast<ValueTypes>(serialized_val[0]);
            if (type == TUPLE) {
                auto tup_val = nonstd::get<Tuple>(current_val);
                auto tuple_save_results = saveTuple(transaction, tup_val);
            }
        }
        return transaction.saveData(key, value_vector);
    }
}
}  // namespace

SaveResults saveValue(Transaction& transaction, const value& val) {
    if (nonstd::holds_alternative<Tuple>(val)) {
        auto tuple = nonstd::get<Tuple>(val);
        return saveTuple(transaction, tuple);
    } else {
        auto serialized_value = checkpoint::utils::serializeValue(val);
        auto hash_key = getHashKey(val);
        auto key = vecToSlice(hash_key);
        return transaction.saveData(key, serialized_value);
    }
}
