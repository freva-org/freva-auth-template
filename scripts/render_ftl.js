const fs = require('fs');
const path = require('path');

function processFtl(content) {
  return content
    // message replacements
    .replace(/\$\{msg\(['"]([^"']+)['"].*?\)\}/g, (match, p1) => {
      const messages = {
        'doLogIn': 'Sign In', 'doRegister': 'Register', 'doForgotPassword': 'Forgot Password',
        'usernameOrEmail': 'Username or email', 'password': 'Password',
        'loginTitle': 'Sign In', 'registerTitle': 'Register', 'backToLogin': 'Back to Login',
      };
      return messages[p1] || p1;
    })
    
    .replace(/\$\{url\.([^}]+)\}/g, '#')
    .replace(/\$\{properties\.([^}]+)\}/g, '')
    .replace(/\$\{realm\.displayName.*?\}/g, 'FREVA Auth Service')
    .replace(/\$\{kcSanitize\(message\.summary\).*?\}/g, '')
    .replace(/\$\{provider\.displayName\}/g, 'Google')
    .replace(/<#if [^>]+>([\s\S]*?)<\/#if>/g, '$1')
    .replace(/<#elseif [^>]+>[\s\S]*?(?=<\/#if>)/g, '')
    .replace(/<#else>[\s\S]*?(?=<\/#if>)/g, '')
    .replace(/<#list [^>]+>([\s\S]*?)<\/#list>/g, '$1')
    .replace(/<#include [^>]+>/g, '')
    .replace(/\$\{[a-zA-Z0-9_]+(\.[a-zA-Z0-9_]+)*\}/g, '');
}

function createPreview(templates, outputPath) {
  const tabs = Object.keys(templates).map(file => {
    const id = file.replace('.ftl', '');
    let title = id.charAt(0).toUpperCase() + id.slice(1).replace(/-/g, ' ');

    if (id === 'login') title = 'Login Page';
    if (id === 'register') title = 'Registration Page';
    if (id === 'login-reset-credentials') title = 'Reset Password';
    
    return { id, title, content: templates[file] };
  });
  
  const preferredOrder = ['login', 'register', 'login-reset-credentials'];
  tabs.sort((a, b) => {
    const indexA = preferredOrder.indexOf(a.id);
    const indexB = preferredOrder.indexOf(b.id);
    return (indexA === -1 ? 999 : indexA) - (indexB === -1 ? 999 : indexB);
  });
  
  const tabButtons = tabs.map((tab, i) => 
    `<button class="tab-button ${i === 0 ? 'active' : ''}" data-tab="${tab.id}">${tab.title}</button>`
  ).join('\n');
  
  const tabPanels = tabs.map((tab, i) => 
    `<div id="${tab.id}" class="tab-panel ${i === 0 ? 'active' : ''}">
      <div class="keycloak-template">${tab.content}</div>
    </div>`
  ).join('\n');
  
  // generate HTML with tab navigation
  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>FREVA Keycloak Theme Preview</title>
  <link rel="stylesheet" href="resources/css/styles.css">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: system-ui, sans-serif; display: flex; height: 100vh; overflow: hidden; }
    .sidebar { width: 25%; background: #f5f5f5; padding: 20px; border-right: 1px solid #ddd; }
    .main-content { width: 75%; overflow-y: auto; padding: 20px; }
    h1 { margin: 0 0 15px 0; color: #333; font-size: 1.8rem; line-height: 1.2; }
    .commit-info { font-size: 0.9rem; color: #6c757d; margin-top: 10px; }
    .tab-navigation { display: flex; border-bottom: 1px solid #dee2e6; margin-bottom: 20px; }
    .tab-button { padding: 10px 20px; background: none; border: 1px solid transparent; 
      border-radius: 4px 4px 0 0; cursor: pointer; font-size: 14px; margin-right: 5px; }
    .tab-button.active { color: #007bff; border: 1px solid #dee2e6; border-bottom-color: #fff; 
      background: #fff; font-weight: 500; margin-bottom: -1px; }
    .tab-panel { display: none; }
    .tab-panel.active { display: block; }
    .keycloak-template { background: #f1f1f1; border-radius: 4px; padding: 20px; min-height: 400px; 
      overflow-y: auto; max-height: calc(100vh - 150px); }
  </style>
</head>
<body>
  <div class="sidebar">
    <h1>FREVA Authentication Theme Preview</h1>
  </div>
  <div class="main-content">
    <div class="tab-navigation">${tabButtons}</div>
    <div class="tab-content">${tabPanels}</div>
  </div>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      const tabs = document.querySelectorAll('.tab-button');
      const panels = document.querySelectorAll('.tab-panel');
      
      tabs.forEach(tab => {
        tab.addEventListener('click', function() {
          const tabId = this.dataset.tab;
          panels.forEach(p => p.classList.remove('active'));
          tabs.forEach(t => t.classList.remove('active'));
          document.getElementById(tabId).classList.add('active');
          this.classList.add('active');
        });
      });
    });
  </script>
</body>
</html>`;

  fs.writeFileSync(outputPath, html);
  console.log(`Created preview at ${outputPath}`);
}



function processTemplates(dir) {
  const templates = {};
  
  if (fs.existsSync(dir)) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
      if (file.endsWith('.ftl')) {
        const ftlPath = path.join(dir, file);
        const content = fs.readFileSync(ftlPath, 'utf8');
        templates[file] = processFtl(content);
      }
    }
  }
  
  return templates;
}

// copying resources from the input directory to the built directory
function copyResources(sourceDir, targetDir) {
  if (!fs.existsSync(sourceDir)) return;
  
  const targetResourceDir = path.join(targetDir, 'resources');
  fs.mkdirSync(targetResourceDir, { recursive: true });
  
  copyDir(sourceDir, targetResourceDir);
  
  console.log(`Copied resources from ${sourceDir} to ${targetResourceDir}`);
}

function copyDir(source, target) {
  const files = fs.readdirSync(source);
  
  for (const file of files) {
    const sourcePath = path.join(source, file);
    const targetPath = path.join(target, file);
    
    if (fs.lstatSync(sourcePath).isDirectory()) {
      fs.mkdirSync(targetPath, { recursive: true });
      copyDir(sourcePath, targetPath);
    } else {
      fs.copyFileSync(sourcePath, targetPath);
    }
  }
}



function main() {
  const inputDir = 'login';
  const outputDir = 'preview-build';

  fs.mkdirSync(outputDir, { recursive: true });

  if (fs.existsSync(path.join(inputDir, 'resources'))) {
    copyResources(path.join(inputDir, 'resources'), outputDir);
  }
  
  const templates = processTemplates(inputDir);
  
  if (Object.keys(templates).length > 0) {
    createPreview(templates, path.join(outputDir, 'index.html'));
    console.log('Preview created successfully!');
  } else {
    console.error('No templates found in', inputDir);
  }
}

if (require.main === module) {
  main();
} else {
  module.exports = {
    processFtl,
    createPreview,
    processTemplates,
    copyResources
  };
}