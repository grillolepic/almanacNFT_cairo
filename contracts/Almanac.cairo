%lang starknet

from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_lt, uint256_le, uint256_add, uint256_sub, uint256_mul, uint256_unsigned_div_rem
from starkware.cairo.common.math_cmp import is_nn_le, is_not_zero
from starkware.cairo.common.math import assert_not_zero, assert_not_equal, assert_lt
from starkware.cairo.common.bool import TRUE, FALSE
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc721_enumerable.library import ERC721_Enumerable
from openzeppelin.introspection.ERC165 import ERC165
from openzeppelin.access.ownable import Ownable

@contract_interface
namespace IVRFProvider:
    func requestRandomNumber(id: Uint256):
    end
    func isRequested(id: Uint256) -> (requested: felt):
    end
    func readRandomNumber(id: Uint256) -> (random: felt):
    end
end

const MAX_SUPPLY = 10000
const PUBLIC_SUPPLY = 9950

struct AlmanacMarketDay:
    member market : felt
    member day : felt
end

@storage_var
func Price() -> (price: Uint256):
end

@storage_var
func Enabled() -> (enabled: felt):
end

@storage_var
func MaxMarket() -> (maxMarket: felt):
end

@storage_var
func MinMarketDate(market: felt) -> (minDate: felt):
end

@storage_var
func BaseUri() -> (baseUri: felt):
end

@storage_var
func PublicMinted() -> (publicMinted: Uint256):
end

@storage_var
func MilestonesMinted() -> (milestonesMinted: Uint256):
end

@storage_var
func MilestonesSetup() -> (milestonesSetup: Uint256):
end

@storage_var
func ShufflingMilestone() -> (milestone: AlmanacMarketDay):
end

@storage_var
func ShufflingId() -> (milestoneId: Uint256):
end

@storage_var
func Almanacs(almanacId: Uint256) -> (almanac: AlmanacMarketDay):
end

@storage_var
func AlmanacMap(almanac: AlmanacMarketDay) -> (almanacId: Uint256):
end

@storage_var
func Milestones(almanacId: Uint256) -> (almanac: AlmanacMarketDay):
end

@storage_var
func MilestoneAlmanacMap(almanac: AlmanacMarketDay) -> (almanacId: Uint256):
end

@storage_var
func VRFProvider() -> (vrfProvider: felt):
end

@storage_var
func Ether() -> (ether: felt):
end



@event
func NewAlmanac(id: Uint256, almanac: AlmanacMarketDay):
end



# >> CONSTRUCTOR

@constructor
func constructor{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner: felt, ether: felt, vrfProvider: felt):
    
    BaseUri.write('https://sn.almanacNFT.xyz/')
    
    Ether.write(ether)
    VRFProvider.write(vrfProvider)

    Price.write(Uint256(3*(10**16),0))
    
    MaxMarket.write(13)
    MinMarketDate.write(0,1827)
    MinMarketDate.write(1,2777)
    MinMarketDate.write(2,2778)
    MinMarketDate.write(3,3642)
    MinMarketDate.write(4,3564)
    MinMarketDate.write(5,4154)
    MinMarketDate.write(6,4615)
    MinMarketDate.write(7,4609)
    MinMarketDate.write(8,4618)
    MinMarketDate.write(9,4650)
    MinMarketDate.write(10,4035)
    MinMarketDate.write(11,3388)
    MinMarketDate.write(12,4880)
    MinMarketDate.write(13,5191)
    
    ERC721.initializer('AlmanacNFT', 'ALMANAC')
    ERC721_Enumerable.initializer()
    Ownable.initializer(owner)
    return()
end



# >> ERC FUNCTIONS

#ERC1615
@view
func supportsInterface{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr }(interfaceId: felt) -> (success: felt):
    let (success) = ERC165.supports_interface(interfaceId)
    return (success)
end

#ERC721
@view
func balanceOf{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr }(owner: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC721.balance_of(owner)
    return (balance)
end

@view
func ownerOf{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr }(tokenId: Uint256) -> (owner: felt):
    let (owner: felt) = ERC721.owner_of(tokenId)
    return (owner)
end

@external
func safeTransferFrom{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr }(from_: felt, to: felt, tokenId: Uint256, data_len: felt, data: felt*):
    assert_only_enabled()
    ERC721_Enumerable.safe_transfer_from(from_, to, tokenId, data_len, data)
    return ()
end

@external
func transferFrom{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr }(from_: felt, to: felt, tokenId: Uint256):
    assert_only_enabled()
    ERC721_Enumerable.transfer_from(from_, to, tokenId)
    return ()
end

@external
func approve{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr }(to: felt, tokenId: Uint256):
    ERC721.approve(to, tokenId)
    return ()
end

@external
func setApprovalForAll{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr }(operator: felt, approved: felt):
    ERC721.set_approval_for_all(operator, approved)
    return ()
end

@view
func getApproved{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr }(tokenId: Uint256) -> (approved: felt):
    let (approved: felt) = ERC721.get_approved(tokenId)
    return (approved)
end

@view
func isApprovedForAll{ syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr }(owner: felt, operator: felt) -> (isApproved: felt):
    let (isApproved: felt) = ERC721.is_approved_for_all(owner, operator)
    return (isApproved)
end

#ERC721Metadata
@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol: felt):
    let (symbol) = ERC721.symbol()
    return (symbol)
end

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name: felt):
    let (name) = ERC721.name()
    return (name)
end

@view
func tokenURI{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(almanacId: Uint256) -> (result: felt):
    alloc_locals
    let (baseUri) = BaseUri.read()

    let (exists, _) = almanacExists(almanacId)
    with_attr error_message("Invalid Id"):
        assert exists = TRUE
    end

    let (is_tens) = uint256_is_in_range_inclusive(almanacId, Uint256(0,0), Uint256(9,0))
    if is_tens == 1:
        return ((baseUri*256)+'0'+almanacId.low)
    else:
        let (is_hundreds) = uint256_is_in_range_inclusive(almanacId, Uint256(0,0), Uint256(99,0))
        if is_hundreds == 1:
            let (a,b) = uint256_unsigned_div_rem(almanacId, Uint256(10,0))
            return ((baseUri*(256**2))+(('0'+a.low)*256)+('0'+b.low))
        else:
            let (is_thousands) = uint256_is_in_range_inclusive(almanacId, Uint256(0,0), Uint256(999,0))
            if is_thousands == 1:
                let (a,b) = uint256_unsigned_div_rem(almanacId, Uint256(100,0))
                let (c,d) = uint256_unsigned_div_rem(b, Uint256(10,0))
                return ((baseUri*(256**3))+(('0'+a.low)*(256**2))+(('0'+c.low)*256)+('0'+d.low))
            else:
                let (is_ten_housands) = uint256_is_in_range_inclusive(almanacId, Uint256(0,0), Uint256(9999,0))
                if is_ten_housands == 1:
                    let (a,b) = uint256_unsigned_div_rem(almanacId, Uint256(1000,0))
                    let (c,d) = uint256_unsigned_div_rem(b, Uint256(100,0))
                    let (e,f) = uint256_unsigned_div_rem(d, Uint256(10,0))
                    return ((baseUri*(256**4))+(('0'+a.low)*(256**3))+(('0'+c.low)*(256**2))+(('0'+e.low)*256)+('0'+f.low))
                else:
                    return ((baseUri*(256**5))+'10000')
                end
            end
        end
    end
end

@external
func setBaseURI{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(newBaseUri: felt):
    Ownable.assert_only_owner()
    BaseUri.write(newBaseUri)
    return ()
end

#ERC721Enumerable
@view
func totalSupply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = ERC721_Enumerable.total_supply()
    return (totalSupply)
end

@view
func tokenOfOwnerByIndex{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner: felt, index: Uint256) -> (tokenId: Uint256):
    let (tokenId: Uint256) = ERC721_Enumerable.token_of_owner_by_index(owner, index)
    return (tokenId)
end

@view
func tokenByIndex{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(index: Uint256) -> (tokenId: Uint256):
    let (tokenId: Uint256) = ERC721_Enumerable.token_by_index(index)
    return (tokenId)
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

@view
func isOwner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (isOwner: felt):
    let (owner) = Ownable.owner()
    let (callerAddress) = get_caller_address()
    if owner == callerAddress:
        return (TRUE)
    end
    return (FALSE)
end



# >> ALMANAC FUNCTIONS

#Minting
@external
func publicMint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(almanac: AlmanacMarketDay, recipient: felt):
    alloc_locals
    assert_only_enabled()

    let (ownerMint) = isOwner()

    let (publicSupply) = getPublicMinted()
    let (startingId) = uint256_sub(Uint256(MAX_SUPPLY,0), Uint256(PUBLIC_SUPPLY,0))
    let (lastId, _) = uint256_add(startingId, publicSupply)
    let (newId, _) = uint256_add(lastId, Uint256(1,0))
    let (isValid) = uint256_is_in_range_inclusive(newId, Uint256(1,0), Uint256(MAX_SUPPLY,0))
    with_attr error_message("Public supply finished"):
        assert isValid = TRUE
    end

    let (maxMarket) = MaxMarket.read()
    let (okMarket) = is_nn_le(almanac.market, maxMarket)
    with_attr error_message("Market not allowed"):
        assert okMarket = TRUE
    end

    let (minDate) = MinMarketDate.read(almanac.market)
    let (okDate) = is_nn_le(minDate, almanac.day)
    with_attr error_message("Below Min Market Date"):
        assert okDate = TRUE
    end

    let (id) = AlmanacMap.read(almanac)
    with_attr error_message("Almanac already exists with same market and date"):
        assert id = Uint256(FALSE,FALSE)
    end

    let (milestoneId) = MilestoneAlmanacMap.read(almanac)
    with_attr error_message("Almanac is a reserved Milestone"):
        assert id = Uint256(FALSE,FALSE)
    end

    let (callerAddress) = get_caller_address()

    if ownerMint == FALSE:
        let (etherAddress) = Ether.read()
        let (thisContractAddress) = get_contract_address()
        let (price) = getPrice()
        let (remainingAllowance) = IERC20.allowance(contract_address = etherAddress, owner = callerAddress, spender = thisContractAddress)
        let (isEnoughAllowance) = uint256_le(price, remainingAllowance)
        with_attr error_message("Not enough allowance for payment"):
            assert isEnoughAllowance = TRUE
        end
        IERC20.transferFrom(contract_address = etherAddress, sender = callerAddress, recipient = thisContractAddress, amount = price)

        ERC721_Enumerable._mint(callerAddress, newId)
    else: 
        ERC721_Enumerable._mint(recipient, newId)
    end

    Almanacs.write(newId, almanac)
    AlmanacMap.write(almanac, newId)
    
    NewAlmanac.emit(newId, almanac)

    let (newPublicMinted, _) = uint256_add(publicSupply, Uint256(1,0))
    PublicMinted.write(newPublicMinted)

    return()
end

#Milestone setup and shuffle
#This function sets up a Milestone, reserving the date (no public mint possible)
@external
func setupMilestone{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(milestone: AlmanacMarketDay):
    alloc_locals
    Ownable.assert_only_owner()

    let (milestonesSetup) = MilestonesSetup.read()
    let (newId, _) = uint256_add(milestonesSetup, Uint256(1,0))
    let (maxMilestoneSupply) = uint256_sub(Uint256(MAX_SUPPLY,0), Uint256(PUBLIC_SUPPLY,0))
    let (isValid) = uint256_is_in_range_inclusive(newId, Uint256(1,0), maxMilestoneSupply)
    with_attr error_message("Milestone limit reached"):
        assert isValid = TRUE
    end

    let (almanacId) = AlmanacMap.read(milestone)
    with_attr error_message("Almanac already exists with same market and date"):
        assert almanacId = Uint256(FALSE,FALSE)
    end

    let (milestoneId) = MilestoneAlmanacMap.read(milestone)
    with_attr error_message("Milestone already exists with same market and date"):
        assert milestoneId = Uint256(FALSE,FALSE)
    end

    Milestones.write(newId, milestone)
    MilestoneAlmanacMap.write(milestone, newId)

    let (newMilestonesSetup, _) = uint256_add(milestonesSetup, Uint256(1,0))
    MilestonesSetup.write(newMilestonesSetup)

    return ()
end

#This functions starts a shuffle for an already setup Milestone,
#Calling the IVRFProvider
@external
func startShuffle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    Ownable.assert_only_owner()

    let (shufflingId) = ShufflingId.read()
    let (notShuffling) = uint256_le(shufflingId, Uint256(FALSE, FALSE))
    with_attr error_message("Can't start a shuffle while shuffling"):
        assert notShuffling = TRUE
    end

    let (milestoneSupply) = getMilestonesMinted()
    let (newId, _) = uint256_add(milestoneSupply, Uint256(1,0))
    let (maxMilestoneSupply) = uint256_sub(Uint256(MAX_SUPPLY,0), Uint256(PUBLIC_SUPPLY,0))
    let (isValid) = uint256_is_in_range_inclusive(newId, Uint256(1,0), maxMilestoneSupply)
    with_attr error_message("Milestone supply finished"):
        assert isValid = TRUE
    end

    let (milestonesSetup) = MilestonesSetup.read()
    let (alreadySetup) = uint256_le(newId, milestonesSetup)
    with_attr error_message("Milestone not setup"):
        assert isValid = TRUE
    end

    let (vrfAddress) = VRFProvider.read()
    let (alreadyRequested) = IVRFProvider.isRequested(contract_address = vrfAddress, id = newId)
    with_attr error_message("Already shuffled"):
        assert alreadyRequested = FALSE
    end

    let (shuffledMilestone) = Milestones.read(newId)

    ShufflingId.write(newId)

    IVRFProvider.requestRandomNumber(contract_address = vrfAddress, id = newId)

    return ()
end

#This function reads the random value, mints and sends the Milestone to the winner
@external
func finishShuffle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    Ownable.assert_only_owner()

    let (milestoneId) = ShufflingId.read()
    let (milestone) = getShufflingMilestone()

    let (vrfAddress) = VRFProvider.read()
    let (randomNumber) = IVRFProvider.readRandomNumber(contract_address = vrfAddress, id = milestoneId)
    with_attr error_message("Not shuffled"):
        assert_not_zero(randomNumber)
    end

    let maxSupply = Uint256(MAX_SUPPLY, 0)
    let maxPublicSupply = Uint256(PUBLIC_SUPPLY, 0)
    let (maxMilestoneSupply) = uint256_sub(maxSupply, maxPublicSupply)
    let (initialId, _) = uint256_add(maxMilestoneSupply, Uint256(1,0))

    let (maxWinnerId) = getPublicMinted()
    let (isZero) = uint256_le(maxWinnerId, Uint256(0,0))
    with_attr error_message("Available participants"):
        assert isZero = FALSE
    end

    let (_,mod) = uint256_unsigned_div_rem(Uint256(randomNumber,0), maxWinnerId)
    let (winner, _) = uint256_add(initialId, mod)
    let (addressOfWinner) = ownerOf(winner)

    milestoneMint(milestone, addressOfWinner)

    ShufflingId.write(Uint256(FALSE, FALSE))

    return()
end

@view
func getShufflingId{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (milestoneId: Uint256):
    let (shufflingId) = ShufflingId.read()
    return (shufflingId)
end

@view
func getShufflingMilestone{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (milestone: AlmanacMarketDay):
    alloc_locals
    let (milestoneId) = ShufflingId.read()
    let (is_zero) = uint256_le(milestoneId, Uint256(0,0))
    with_attr error_message("No Milestone being shuffled"):
        assert is_zero = FALSE
    end

    let (shufflingMilestone) = Milestones.read(milestoneId)
    return (shufflingMilestone)
end

func milestoneMint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(almanac: AlmanacMarketDay, address: felt):
    alloc_locals
    Ownable.assert_only_owner()

    let (milestoneSupply) = getMilestonesMinted()
    let (newId, _) = uint256_add(milestoneSupply, Uint256(1,0))
    let (maxMilestoneSupply) = uint256_sub(Uint256(MAX_SUPPLY,0), Uint256(PUBLIC_SUPPLY,0))
    let (isValid) = uint256_is_in_range_inclusive(newId, Uint256(1,0), maxMilestoneSupply)
    with_attr error_message("Milestone supply finished"):
        assert isValid = TRUE
    end

    let (id) = AlmanacMap.read(almanac)
    with_attr error_message("Almanac already exists with same market and date"):
        assert id = Uint256(FALSE,FALSE)
    end

    Almanacs.write(newId, almanac)
    AlmanacMap.write(almanac, newId)
    
    NewAlmanac.emit(newId, almanac)

    ERC721_Enumerable._mint(address, newId)

    let (newMilestonesMinted, _) = uint256_add(milestoneSupply, Uint256(1,0))
    MilestonesMinted.write(newMilestonesMinted)
    return()
end

#VRF
@view
func getVrfProvider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (vrfProvider: felt):
    let (vrf) = VRFProvider.read()
    return (vrf)
end

@external
func setVrfProvider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(vrfProvider: felt):
    Ownable.assert_only_owner()
    VRFProvider.write(vrfProvider)
    return()
end

#Almanacs
@view
func getAlmanacInfo{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(almanacId: Uint256) -> (almanac: AlmanacMarketDay):
    alloc_locals
    let (exists, _) = almanacExists(almanacId)
    with_attr error_message("Invalid Id"):
        assert exists = TRUE
    end
    let (almanac) = Almanacs.read(almanacId)
    return (almanac)
end

@view
func getAlmanac{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(almanac: AlmanacMarketDay) -> (almanacId: Uint256):
    alloc_locals
    let (id) = AlmanacMap.read(almanac)
    return (id) 
end

#Supply
@view
func getPublicMinted{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (publicMinted: Uint256):
    let (publicMinted) = PublicMinted.read()
    return (publicMinted)
end

@view
func getMilestonesMinted{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (milestonesMinted: Uint256):
    let (milestonesMinted) = MilestonesMinted.read()
    return (milestonesMinted)
end

#Allowed Markets and Min Dates
@view
func getMaxMarket{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (maxMarket: felt):
    let (max) = MaxMarket.read()
    return (max)
end

@external
func setMaxMarket{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(marketId: felt):
    alloc_locals
    Ownable.assert_only_owner()

    let (currentMaxMarket) = MaxMarket.read()
    local current = currentMaxMarket
    let (isLoweOrEqual) = is_nn_le(marketId, current)
    with_attr error_message("Lower max market"):
        assert isLoweOrEqual = FALSE
    end
    
    MaxMarket.write(marketId)
    return()
end

@view
func getMinMarketDate{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(marketId: felt) -> (minMarket: felt):
    let (min) = MinMarketDate.read(marketId)
    return (min)
end

@external
func setMinMarketDate{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(marketId: felt, minDate: felt):
    alloc_locals
    Ownable.assert_only_owner()   
    MinMarketDate.write(marketId, minDate)
    return()
end

#Enabled
@view
func isEnabled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (enabled: felt):
    let (enabled) = Enabled.read()
    return (enabled)
end

@external
func setEnabled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(enabled: felt):
    Ownable.assert_only_owner()
    let (setToEnabled) = is_not_zero(enabled)
    if setToEnabled == TRUE:
        Enabled.write(TRUE)
    else:
        Enabled.write(FALSE)
    end
    return ()
end

#Price
@view
func getPrice{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (price: Uint256):
    let (price) = Price.read()
    return (price)
end

@external
func setPrice{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(newPrice: Uint256):
    Ownable.assert_only_owner()
    Price.write(newPrice)
    return ()
end

@external
func setEther{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(newEther: felt):
    Ownable.assert_only_owner()
    Ether.write(newEther)
    return ()
end

#Withdraw
@external
func withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    Ownable.assert_only_owner()

    let (etherAddress) = Ether.read()
    let (thisContractAddress) = get_contract_address()
    let (currentBalance) = IERC20.balanceOf(contract_address = etherAddress, account = thisContractAddress)

    let (notZero) = uint256_lt(Uint256(0,0), currentBalance)
    with_attr error_message("Balance is 0 ETH"):
        assert notZero = TRUE
    end
    
    let (withdrawAddress) = owner()

    let (success1) = IERC20.transfer(contract_address = etherAddress, recipient = withdrawAddress, amount = currentBalance)
    with_attr error_message("Transfer to DEV_WALLET failed"):
        assert success1 = TRUE
    end

    return ()
end



# >>INTERNAL FUNCTIONS
func almanacExists{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(almanacId: Uint256) -> (res: felt, isMilestone: felt):
    alloc_locals
    let (is_zero) = uint256_le(almanacId, Uint256(0,0))
    if is_zero == TRUE:
        return (FALSE, FALSE)
    end

    let maxSupply = Uint256(MAX_SUPPLY, 0)
    let maxPublicSupply = Uint256(PUBLIC_SUPPLY, 0)
    let (maxMilestoneSupply) = uint256_sub(maxSupply, maxPublicSupply)

    let (isIdMilestone) = uint256_le(almanacId, maxMilestoneSupply)

    if isIdMilestone == TRUE:
        let (currentMilestoneSupply) = getMilestonesMinted()
        let (exists) = uint256_le(almanacId, currentMilestoneSupply)
        return (exists, isIdMilestone)
    else:
        let (currentPublicSupply) = getPublicMinted()
        let (currentMaxPublicId, _) = uint256_add(maxMilestoneSupply, currentPublicSupply)
        let (exists) = uint256_le(almanacId, currentMaxPublicId)
        return (exists, isIdMilestone)
    end
end

func uint256_is_in_range_inclusive{range_check_ptr}(value: Uint256, lower: Uint256, upper: Uint256) -> (res: felt):
    let (res) = uint256_le(lower, value)
    if res == FALSE:
        return (FALSE)
    end
    return uint256_le(value, upper)
end

func assert_only_enabled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (enabled) = Enabled.read()
    with_attr error_message("Disabled"):
        assert enabled = TRUE
    end
    return()
end