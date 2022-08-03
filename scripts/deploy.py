def run(nre):

    nre.compile(["contracts/CentralVRFProvider.cairo"])
    nre.compile(["contracts/Almanac.cairo"])

    owner = "0x03647751Fe490fa5A5c7dE1b729FB7753718eEC12C52DB14281703aa9Dfcf085"
    ether = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"

    print("Deploying Almanac...")
    (almanacAddress, _) = nre.deploy("Almanac", [owner, ether, "0x0"], alias="almanac")
    print(f"Almanac Address: {almanacAddress}")

    print("Deploying CentralVRFProvider...")
    (vrfAddress, _) = nre.deploy("CentralVRFProvider", [owner, almanacAddress], alias="vrf")
    print(f"VRF Address: {vrfAddress}")