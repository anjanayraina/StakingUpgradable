
// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// File: StakingUpgrade/Staking.sol

pragma solidity ^0.8.7;


contract Staking {
    using Address for address;

    // Parameters
    uint128 public constant VALIDATOR_THRESHOLD = 0.0001 ether;

    // Properties
    address[] public _validators;

    mapping(address => bool) public _addressToIsValidator;
    mapping(address => uint256) public _addressToStakedAmount;
    mapping(address => uint256) public _addressToValidatorIndex;
    uint256 public _stakedAmount;
    uint256 public _minimumNumValidators;
    uint256 public _maximumNumValidators;

    mapping(address => bytes) public _addressToBLSPublicKey;

    // Events
    event Staked(address indexed account, uint256 amount);

    event Unstaked(address indexed account, uint256 amount);

    event BLSPublicKeyRegistered(address indexed accout, bytes key);



    // Modifiers
    // modifier onlyEOA() {
    //     require(address(msg.sender).isContract(), "Only EOA can call function");
    //     _;
    // }

    modifier onlyStaker() {
        require(
            _addressToStakedAmount[msg.sender] > 0,
            "Only staker can call function"
        );
        _;
    }

    modifier onlyValidator() {
        require(_isValidator(msg.sender), "Only validator can call function");
        _;
    }

    constructor(uint256 minNumValidators, uint256 maxNumValidators) {
        require(
            minNumValidators <= maxNumValidators,
            "Min validators num can not be greater than max num of validators"
        );
        _minimumNumValidators = minNumValidators;
        _maximumNumValidators = maxNumValidators;
    }

    // View functions
    function stakedAmount() public view returns (uint256) {
        return _stakedAmount;
    }

    function validators() public view returns (address[] memory) {
        return _validators;
    }

    function validatorBLSPublicKeys() public view returns (bytes[] memory) {
        bytes[] memory keys = new bytes[](_validators.length);

        for (uint256 i = 0; i < _validators.length; i++) {
            keys[i] = _addressToBLSPublicKey[_validators[i]];
        }

        return keys;
    }

    function isValidator(address addr) public view returns (bool) {
        return _addressToIsValidator[addr];
    }

    function accountStake(address addr) public view returns (uint256) {
        return _addressToStakedAmount[addr];
    }

    function minimumNumValidators() public view returns (uint256) {
        return _minimumNumValidators;
    }

    function maximumNumValidators() public view returns (uint256) {
        return _maximumNumValidators;
    }

    // Public functions
    receive() external payable  {
        _stake();
    }

    function stake() public payable  {
        _stake();
    }

    function unstake() public  onlyStaker {
        _unstake();
    }

    function registerBLSPublicKey(bytes memory blsPubKey) public {
        _addressToBLSPublicKey[msg.sender] = blsPubKey;

        emit BLSPublicKeyRegistered(msg.sender, blsPubKey);
    }

    // Private functions
    function _stake() private {
        _stakedAmount += msg.value;
        _addressToStakedAmount[msg.sender] += msg.value;

        if (_canBecomeValidator(msg.sender)) {
            _appendToValidatorSet(msg.sender);
        }

        emit Staked(msg.sender, msg.value);
    }

    function _unstake() private {
        uint256 amount = _addressToStakedAmount[msg.sender];

        _addressToStakedAmount[msg.sender] = 0;
        _stakedAmount -= amount;

        if (_isValidator(msg.sender)) {
            _deleteFromValidators(msg.sender);
        }

        payable(msg.sender).transfer(amount);
        emit Unstaked(msg.sender, amount);
    }

    function _deleteFromValidators(address staker) private {
        require(
            _validators.length > _minimumNumValidators,
            "Validators can't be less than the minimum required validator num"
        );

        require(
            _addressToValidatorIndex[staker] < _validators.length,
            "index out of range"
        );

        // index of removed address
        uint256 index = _addressToValidatorIndex[staker];
        uint256 lastIndex = _validators.length - 1;

        if (index != lastIndex) {
            // exchange between the element and last to pop for delete
            address lastAddr = _validators[lastIndex];
            _validators[index] = lastAddr;
            _addressToValidatorIndex[lastAddr] = index;
        }

        _addressToIsValidator[staker] = false;
        _addressToValidatorIndex[staker] = 0;
        _validators.pop();
    }

    function _appendToValidatorSet(address newValidator) private {
        require(
            _validators.length < _maximumNumValidators,
            "Validator set has reached full capacity"
        );

        _addressToIsValidator[newValidator] = true;
        _addressToValidatorIndex[newValidator] = _validators.length;
        _validators.push(newValidator);
    }

    function _isValidator(address account) private view returns (bool) {
        return _addressToIsValidator[account];
    }

    function _canBecomeValidator(address account) private view returns (bool) {
        return
            !_isValidator(account) &&
            _addressToStakedAmount[account] >= VALIDATOR_THRESHOLD;
    }
}