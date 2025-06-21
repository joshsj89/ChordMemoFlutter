// Print the lines of a file from the end to the beginning
const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'chord_type_regex.in');

function reverseLines(filePath) {
    try {
        const inputFile = fs.readFileSync(filePath, 'utf8');
        const lines = inputFile.split('\n');
        const reversedLines = lines.reverse();
        const outputFile = path.join(__dirname, 'chord_type_regex.out');
        fs.writeFileSync(outputFile, reversedLines.join('\n'), 'utf8');

        console.log(`Reversed lines written to ${outputFile}`);
    } catch (error) {
        console.error(`Error reading or writing file: ${error.message}`);
    }
}

reverseLines(filePath);