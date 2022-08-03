%lang starknet

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.bool import TRUE, FALSE
from openzeppelin.access.ownable import Ownable

@storage_var
func Almanac() -> (almanac: felt):
end

@storage_var
func RequestedRandomNumbers(index: Uint256) -> (requestId: felt):
end

@storage_var
func GeneratedRandomNumber(index: Uint256) -> (random: felt):
end

@event
func RandomNumberRequested(index: Uint256):
end

@event
func RandomNumberSet(index: Uint256, random: felt):
end

@constructor
func constructor{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner: felt, almanac: felt):
    Ownable.initializer(owner)
    Almanac.write(almanac)
    return()
end

@external
func requestRandomNumber{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id: Uint256):
    let (almanac) = Almanac.read()
    let (caller_address) = get_caller_address()
    with_attr error_message("Only callable by Almanac"):
        assert almanac = caller_address
    end

    let (isReq) = isRequested(id)
    with_attr error_message("Already Requested"):
        assert isReq = FALSE
    end

    RequestedRandomNumbers.write(id, TRUE)
    RandomNumberRequested.emit(id)
    return()
end

@external
func setRandomNumber{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id: Uint256, random: felt):
    Ownable.assert_only_owner()
    let (rnd) = GeneratedRandomNumber.read(id)
    with_attr error_message("Already set"):
        assert rnd = FALSE
    end
    GeneratedRandomNumber.write(id, random)
    RandomNumberSet.emit(id, random)
    return ()
end

@view
func readRandomNumber{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id: Uint256) -> (random: felt):
    let (rnd) = GeneratedRandomNumber.read(id)
    with_attr error_message("Not set"):
        assert_not_zero(rnd)
    end
    return (rnd)
end

@view
func isRequested{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id: Uint256) -> (requested: felt):
    let (rnd) = RequestedRandomNumbers.read(id)
    let (isNotZero) = is_not_zero(rnd)
    return (isNotZero)
end


#Ownable
@external
func renounceOwnership{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    Ownable.renounce_ownership()
    return ()
end

@external
func transferOwnership{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(newOwner: felt):
    Ownable.transfer_ownership(newOwner)
    return ()
end

@view
func owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (owner: felt):
    let (owner) = Ownable.owner()
    return (owner)
end