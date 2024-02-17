import streamlit as st
def analyze_contract(source_code):
    vulnerabilities = []

    # Check 1: Using strict equality is a vulnerability
    if 'address(this).balance == 100 ether' in source_code:
        vulnerabilities.append("Potential vulnerability: Strict equality check in fund_reached")

    # Check 2: Using 'from' field is dangerous
    if 'IERC20(USDC).transferFrom(_from, _to, _amount)' in source_code:
        vulnerabilities.append("Potential vulnerability: Usage of 'from' field in USDCTransfer")

    # Check 3: Anyone can kill the contract
    if 'selfdestruct(payable(msg.sender))' in source_code:
        vulnerabilities.append("Potential vulnerability: Anyone can kill the contract in kill")

    # Check 4: Using delegate should only be done on trusted contracts
    if '_to.delegatecall(_data)' in source_code:
        vulnerabilities.append("Potential vulnerability: Delegate call without checking the target address in delegate")

    # Check 5: Reentrancy attack
    if 'balances[msg.sender] -= _amount' in source_code:
        vulnerabilities.append("Potential vulnerability: Reentrancy attack in withdraw")

    # Check 6: Using Block.timestamp for random number generation
    if 'lotteryWinningNumber = uint256(block.timestamp) % 10' in source_code:
        vulnerabilities.append("Potential vulnerability: Insecure random number generation in winLottery")

    # Check 7: Division before multiplication
    if 'amt = (a / b) * c' in source_code:
        vulnerabilities.append("Potential vulnerability: Division before multiplication in divideBeforeMultiply")

    # Check 8: Usage of Tx.origin
    if 'require(tx.origin == owner)' in source_code:
        vulnerabilities.append("Potential vulnerability: Usage of Tx.origin in txOriginExploit")

    # Check 9: Uninitialized 'to' address
    if '(bool result, ) = to.call{value: address(this).balance}("")' in source_code:
        vulnerabilities.append("Potential vulnerability: Uninitialized 'to' address in transferMoney")

    # Check 10: Incorrect usage of storage and memory variables
    if 'f1(x)' in source_code or 'f2(x)' in source_code:
        vulnerabilities.append("Potential vulnerability: Incorrect usage of storage and memory variables in f, f1, and f2")

      # Check 11: Ownership check for 51%
    if 'uint256 totalSupply = IERC20(USDC).totalSupply();' in source_code and 'uint256 balance = IERC20(USDC).balanceOf(_address);' in source_code and '(balance * 100 / totalSupply >= ownershipThreshold)' in source_code:
          vulnerabilities.append("Potential vulnerability: User with 51% of the total supply ")



    return vulnerabilities

def read_solidity_code_from_file(file_path):
    try:
        with open(file_path, 'r') as file:
            source_code = file.read()
        return source_code
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return None

def main():

    solidity_file_path = "improper.sol"


    source_code = read_solidity_code_from_file(solidity_file_path)

    if source_code:
        vulnerabilities = analyze_contract(source_code)

        if vulnerabilities:
          print("Potential vulnerabilities found:")
          st.write(vulnerabilities)  
          for vulnerability in vulnerabilities:
                print("-", vulnerability)
                st.write("-" + vulnerability)
        else:
            print("No potential vulnerabilities detected.")
    else:
        print("Exiting due to file read error.")

if __name__ == "__main__":
    main()
