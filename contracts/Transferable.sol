// SPDX-License-Identifier: MIT
// Creator: Charlie Benson, based upon OpenZeppelin Pausable.sol (v4.7.0)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotTransferable` and `whenTransferable`, which can be applied to
 * the functions of your contract. Note that they will not be Transferable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Transferable is Context {
    /**
     * @dev Emitted when the transferable is triggered by `account`.
     */
    event IsTransferable(address account);

    /**
     * @dev Emitted when the transferable is lifted by `account`.
     */
    event IsNotTransferable(address account);

    bool private _transferable;

    /**
     * @dev Initializes the contract in untransferable state.
     */
    constructor() {
        _transferable = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not transferable.
     *
     * Requirements:
     *
     * - The contract must not be transferable.
     */
    modifier whenNotTransferable() {
        _requireNotTransferable();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is transferable.
     *
     * Requirements:
     *
     * - The contract must be transferable.
     */
    modifier whenTransferable() {
        _requireTransferable();
        _;
    }

    /**
     * @dev Returns true if the contract is transferable, and false otherwise.
     */
    function transferable() public view virtual returns (bool) {
        return _transferable;
    }

    /**
     * @dev Throws if the contract is transferable.
     */
    function _requireNotTransferable() internal view virtual {
        require(!transferable(), "Transferable: transferable");
    }

    /**
     * @dev Throws if the contract is not transferable.
     */
    function _requireTransferable() internal view virtual {
        require(transferable(), "Transferable: not transferable");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be transferable.
     */
    function _makeTransferable() internal virtual whenNotTransferable {
        _transferable = true;
        emit IsTransferable(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be transferable.
     */
    function _makeNotTransferable() internal virtual whenTransferable {
        _transferable = false;
        emit IsNotTransferable(_msgSender());
    }
}