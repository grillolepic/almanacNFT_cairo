%lang starknet

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_block_number, get_block_timestamp

@storage_var
func Almanac() -> (almanac: felt) {
}

@storage_var
func GeneratedRandomNumber(index: Uint256) -> (random: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    almanac: felt
) {
    Almanac.write(almanac);
    return ();
}

@external
func requestRandomNumber{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: Uint256
) {
    alloc_locals;

    let (almanac) = Almanac.read();
    let (caller_address) = get_caller_address();
    with_attr error_message("Only callable by Almanac") {
        assert almanac = caller_address;
    }

    let (isReq) = isRequested(id);
    with_attr error_message("Already Requested") {
        assert isReq = FALSE;
    }

    let (blockNumber) = get_block_number();
    let (blockTimestamp) = get_block_timestamp();

    let (_, rem) = unsigned_div_rem(blockTimestamp, 2);
    
    if (rem == 0) {
        let (hash) = hash2{hash_ptr=pedersen_ptr}(blockNumber, blockTimestamp);
    } else {
        let (hash) = hash2{hash_ptr=pedersen_ptr}(blockTimestamp, blockNumber);
    }

    GeneratedRandomNumber.write(id, hash);
    return ();
}

@view
func readRandomNumber{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: Uint256
) -> (random: felt) {
    let (rnd) = GeneratedRandomNumber.read(id);
    with_attr error_message("Not set") {
        assert_not_zero(rnd);
    }
    return (rnd,);
}

@view
func isRequested{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(id: Uint256) -> (
    requested: felt
) {
    let (rnd) = GeneratedRandomNumber.read(id);
    let isNotZero = is_not_zero(rnd);
    return (isNotZero,);
}