require("@nomicfoundation/hardhat-toolbox");
require("@shardlabs/starknet-hardhat-plugin");

module.exports = {
  starknet: {
    venv: "active"
  },
  paths: {
    cairoPaths: [
      "contract/lib",
      "~/cairo_venv/lib/python3.9/site-packages"
    ]
  }
};
