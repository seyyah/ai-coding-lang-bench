const fs = require('fs');
const { execFileSync } = require('child_process');

const prData = JSON.parse(fs.readFileSync('pr_list.json', 'utf-8'));

function runGhCommand(args) {
  try {
    console.log(`Executing: gh ${args.join(' ')}`);
    execFileSync('gh', args, { stdio: 'inherit' });
  } catch (error) {
    console.error(`Failed to execute gh ${args[0]} for PR`);
  }
}

for (const pr of prData) {
  let isValid = true;
  let errorMessages = [];

  // 1. Title format check
  if (!/^\[.*?\]\s/.test(pr.title)) {
    isValid = false;
    errorMessages.push(`- PR title "${pr.title}" inside invalid format. Title must strictly follow '[component] Brief description' format (e.g., '[problem] Add minipomodoro').`);
  }

  // 2. File and path conventions
  for (const file of pr.files) {
    const path = file.path;

    if (path.startsWith('problems/')) {
       const parts = path.split('/');
       if (parts.length > 2) {
         const problemName = parts[1];
         if (!problemName.startsWith('mini')) {
           isValid = false;
           errorMessages.push(`- Problem name '${problemName}' must start with 'mini' prefix.`);
         }
         if (!/^[a-z]+$/.test(problemName)) {
           isValid = false;
           errorMessages.push(`- Problem name '${problemName}' inside 'problems/' must be all lowercase and without hyphens or special characters.`);
         }
       }
    } else {
       if (
         path.toLowerCase().includes('spec') || 
         path.toLowerCase().startsWith('solution') || 
         path.toLowerCase().startsWith('test_') || 
         path.toLowerCase().startsWith('test-') || 
         (path.endsWith('.py') && !path.startsWith('artifacts/') && path !== 'plot.py' && path !== 'prepare.py' && path !== 'tests.py') ||
         path.startsWith('problem.json')
       ) {
         isValid = false;
         errorMessages.push(`- Problem files like '${path}' should be placed inside 'problems/mini<name>/' folder, not in the root directory.`);
       }
       if (path.includes('<') || path.includes('>')) {
         isValid = false;
         errorMessages.push(`- File '${path}' contains invalid characters like '<' or '>'.`);
       }
    }
  }

  errorMessages = [...new Set(errorMessages)];

  if (isValid) {
    console.log(`PR #${pr.number} is VALID.`);
    const msg = "Teşekkürler! Gerekli şartlar sağlandığı için PR kabul edildi ve merge ediliyor.\n\nThank you! The PR meets the criteria and is being merged.";
    runGhCommand(['pr', 'comment', pr.number.toString(), '-b', msg]);
    runGhCommand(['pr', 'merge', pr.number.toString(), '--squash', '--admin']);
    // Fallback if --admin not allowed
  } else {
    console.log(`PR #${pr.number} is INVALID.`);
    const reasons = errorMessages.join("\n");
    const msg = `Bu PR maalesef projenin AGENT.md belgesindeki kurallara uymadığı için kapatılıyor. Lütfen şartları inceleyerek düzeltmeleri yaptıktan sonra yeni bir PR açın.\n\nThis PR is being closed because it violates project conventions:\n\n${reasons}\n\nPlease review AGENT.md (PR guidelines & New problem checklist) and submit a new PR once the structure matches the conventions.`;
    runGhCommand(['pr', 'close', pr.number.toString(), '-c', msg]);
  }
}
