// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "safe-contracts/GnosisSafe.sol";
import "safe-contracts/common/Enum.sol";
import "safe-contracts/base/ModuleManager.sol";
import "./helpers/SafeDeployer.sol";
import "../src/ExampleModule.sol";

contract ExampleModuleTest is SafeDeployer, Test {
    ExampleModule public module;
    GnosisSafe public safe;

    function setUp() public {
        // Setup safe owners
        address[] memory owners = new address[](3);
        owners[0] = address(address(this));
        owners[1] = address(address(5));
        owners[2] = address(address(6));

        // Deploy safe
        safe = super.deploySafe({owners: owners, threshold: 1});

        // Deploy module
        module = new ExampleModule();

        // Enable module on Safe
        // This assumes that threshold for safe will be 1, and that this contract is one of the safe owners
        safe.execTransaction({
            to: address(safe),
            value: 0,
            data: abi.encodeCall(ModuleManager.enableModule, (address(module))),
            operation: Enum.Operation.Call,
            safeTxGas: 0,
            baseGas: 0,
            gasPrice: 0,
            gasToken: address(0),
            refundReceiver: payable(address(0)),
            signatures: bytes(
                hex"0000000000000000000000007FA9385bE102ac3EAc297483Dd6233D62b3e14960000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                )
        });

        assert(safe.isModuleEnabled(address(module)) == true);
    }

    function testOwnerSwap() external {
        address newOwner = address(1337);
        module.swapOwner(safe, newOwner);
        assert(safe.getOwners()[0] == newOwner);
    }
}
