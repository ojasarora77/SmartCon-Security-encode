// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

contract MutationGenerator is Test {
    enum MutationType {
        Arithmetic, // *, /
        Conditional, // >=, >, ==, etc.
        Logical, // &&, ||
        Assignment // =
    }

    struct Mutation {
        string originalLine;
        string mutatedLine;
        uint256 lineNumber;
        MutationType mutationType;
    }

    Mutation[] public mutations;

    struct MutationOperator {
        string original;
        string replacement;
        MutationType mutationType;
    }

    MutationOperator[] public operators;

    constructor() {
        // Conditional operators (without spaces to catch all variants)
        operators.push(
            MutationOperator({
                original: ">=",
                replacement: ">",
                mutationType: MutationType.Conditional
            })
        );
        operators.push(
            MutationOperator({
                original: ">",
                replacement: ">=",
                mutationType: MutationType.Conditional
            })
        );
        operators.push(
            MutationOperator({
                original: "==",
                replacement: "!=",
                mutationType: MutationType.Conditional
            })
        );

        // Logical operators
        operators.push(
            MutationOperator({
                original: "&&",
                replacement: "||",
                mutationType: MutationType.Logical
            })
        );
        operators.push(
            MutationOperator({
                original: "||",
                replacement: "&&",
                mutationType: MutationType.Logical
            })
        );

        // Arithmetic operators
        operators.push(
            MutationOperator({
                original: "*",
                replacement: "/",
                mutationType: MutationType.Arithmetic
            })
        );
        operators.push(
            MutationOperator({
                original: "/",
                replacement: "*",
                mutationType: MutationType.Arithmetic
            })
        );
    }

    function generateMutations(string memory sourceCode) public {
        delete mutations;

        string[] memory lines = _splitLines(sourceCode);

        for (uint256 i = 0; i < lines.length; i++) {
            string memory line = lines[i];

            // Skip irrelevant lines
            if (_shouldSkipLine(line)) continue;

            // Check each operator
            for (uint256 j = 0; j < operators.length; j++) {
                if (_safeContains(line, operators[j].original)) {
                    string memory mutatedLine = _safeReplace(
                        line,
                        operators[j].original,
                        operators[j].replacement
                    );

                    // Verify this mutation wouldn't be unsafe
                    if (!_isUnsafeMutation(line, operators[j])) {
                        mutations.push(
                            Mutation({
                                originalLine: line,
                                mutatedLine: mutatedLine,
                                lineNumber: i + 1,
                                mutationType: operators[j].mutationType
                            })
                        );

                        console2.log("\nFound mutation at line", i + 1);
                        console2.log("Original:", line);
                        console2.log("Mutated:", mutatedLine);
                    }
                }
            }
        }
    }

    function _shouldSkipLine(string memory line) internal pure returns (bool) {
        bytes memory lineBytes = bytes(line);
        if (lineBytes.length == 0) return true;

        // Trim leading whitespace
        uint256 start = 0;
        while (
            start < lineBytes.length &&
            (lineBytes[start] == " " || lineBytes[start] == "\t")
        ) {
            start++;
        }
        if (start == lineBytes.length) return true;

        // Check for comments and imports
        return
            _startsWith(_slice(line, start), "//") ||
            _startsWith(_slice(line, start), "import") ||
            _startsWith(_slice(line, start), "pragma");
    }

    function _slice(
        string memory str,
        uint256 start
    ) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        require(start <= strBytes.length, "Invalid slice");

        bytes memory result = new bytes(strBytes.length - start);
        for (uint i = 0; i < result.length; i++) {
            result[i] = strBytes[start + i];
        }
        return string(result);
    }

    function _isUnsafeMutation(
        string memory line,
        MutationOperator memory operator
    ) internal pure returns (bool) {
        // Skip mutations in constructors or involving owner checks
        if (
            _safeContains(line, "constructor") || _safeContains(line, "owner")
        ) {
            return true;
        }

        // Don't mutate basic initialization
        if (_safeContains(line, "= 0") || _safeContains(line, "= false")) {
            return true;
        }

        // Don't mutate array access
        if (_safeContains(line, "[]")) {
            return true;
        }

        return false;
    }

    function _startsWith(
        string memory str,
        string memory prefix
    ) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory prefixBytes = bytes(prefix);

        if (strBytes.length < prefixBytes.length) return false;

        for (uint i = 0; i < prefixBytes.length; i++) {
            if (strBytes[i] != prefixBytes[i]) return false;
        }
        return true;
    }

    function _safeContains(
        string memory source,
        string memory search
    ) internal pure returns (bool) {
        bytes memory sourceBytes = bytes(source);
        bytes memory searchBytes = bytes(search);

        if (
            searchBytes.length == 0 || sourceBytes.length < searchBytes.length
        ) {
            return false;
        }

        for (
            uint256 i = 0;
            i < sourceBytes.length - searchBytes.length + 1;
            i++
        ) {
            bool found = true;
            for (uint256 j = 0; j < searchBytes.length; j++) {
                if (sourceBytes[i + j] != searchBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return true;
        }
        return false;
    }

    function _safeReplace(
        string memory source,
        string memory search,
        string memory replacement
    ) internal pure returns (string memory) {
        bytes memory sourceBytes = bytes(source);
        bytes memory searchBytes = bytes(search);
        bytes memory replacementBytes = bytes(replacement);

        if (
            sourceBytes.length == 0 ||
            searchBytes.length == 0 ||
            sourceBytes.length < searchBytes.length
        ) {
            return source;
        }

        // Pre-calculate maximum possible length
        uint256 maxLength = sourceBytes.length +
            (
                replacementBytes.length > searchBytes.length
                    ? replacementBytes.length - searchBytes.length
                    : 0
            ) *
            (sourceBytes.length / searchBytes.length + 1);

        bytes memory resultBytes = new bytes(maxLength);
        uint256 resultLength = 0;

        for (uint256 i = 0; i < sourceBytes.length; ) {
            bool found = false;

            if (i <= sourceBytes.length - searchBytes.length) {
                found = true;
                for (uint256 j = 0; j < searchBytes.length; j++) {
                    if (sourceBytes[i + j] != searchBytes[j]) {
                        found = false;
                        break;
                    }
                }
            }

            if (found) {
                for (uint256 j = 0; j < replacementBytes.length; j++) {
                    if (resultLength < maxLength) {
                        resultBytes[resultLength++] = replacementBytes[j];
                    }
                }
                i += searchBytes.length;
            } else {
                if (resultLength < maxLength) {
                    resultBytes[resultLength++] = sourceBytes[i];
                }
                i++;
            }
        }

        // Create final result with exact length
        bytes memory finalResult = new bytes(resultLength);
        for (uint256 i = 0; i < resultLength; i++) {
            finalResult[i] = resultBytes[i];
        }

        return string(finalResult);
    }

    function _splitLines(
        string memory source
    ) internal pure returns (string[] memory) {
        bytes memory sourceBytes = bytes(source);

        // Count lines
        uint256 lineCount = 1;
        for (uint256 i = 0; i < sourceBytes.length; i++) {
            if (sourceBytes[i] == 0x0A) {
                // newline character
                lineCount++;
            }
        }

        string[] memory lines = new string[](lineCount);
        uint256 currentLine = 0;
        uint256 lastNewline = 0;

        // Split into lines
        for (uint256 i = 0; i < sourceBytes.length; i++) {
            if (sourceBytes[i] == 0x0A || i == sourceBytes.length - 1) {
                uint256 length;
                if (i == sourceBytes.length - 1) {
                    length = i - lastNewline + 1;
                } else {
                    length = i - lastNewline;
                }

                bytes memory lineBytes = new bytes(length);
                for (uint256 j = 0; j < length; j++) {
                    lineBytes[j] = sourceBytes[lastNewline + j];
                }

                lines[currentLine] = string(lineBytes);
                currentLine++;
                lastNewline = i + 1;
            }
        }

        return lines;
    }

    // Public view functions
    function getMutationsCount() public view returns (uint256) {
        return mutations.length;
    }

    function getMutation(
        uint256 index
    )
        public
        view
        returns (
            string memory originalLine,
            string memory mutatedLine,
            uint256 lineNumber,
            MutationType mutationType
        )
    {
        require(index < mutations.length, "Index out of bounds");
        Mutation memory mutation = mutations[index];
        return (
            mutation.originalLine,
            mutation.mutatedLine,
            mutation.lineNumber,
            mutation.mutationType
        );
    }

    // For backward compatibility and external use
    function contains(
        string memory source,
        string memory search
    ) public pure returns (bool) {
        return _safeContains(source, search);
    }
}
