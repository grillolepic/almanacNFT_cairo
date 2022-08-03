def run(nre):

    nre.compile(["contracts/CentralVRFProvider.cairo"])
    nre.compile(["contracts/Almanac.cairo"])

    owner = ""
    ether = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"

    print("Deploying Almanac...")
    (almanacAddress, _) = nre.deploy("Almanac", [owner, ether, "0x0"], alias="almanac")
    #almanacAddress = ""
    print(f"Almanac Address: {almanacAddress}")

    print("Deploying CentralVRFProvider...")
    (vrfAddress, _) = nre.deploy("CentralVRFProvider", [owner, almanacAddress], alias="vrf")
    #vrfAddress = ""
    print(f"VRF Address: {vrfAddress}")