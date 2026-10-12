const fs = require('fs');
const path = require('path');

function processFtl(content, props = {}, resolveInclude = () => '') {
  return content
    // inline <#include "file.ftl"> from the theme chain (child first)
    .replace(/<#include\s+"([^"]+)"\s*>/g, (m, name) => resolveInclude(name))
    // ${properties.key!'default'} and ${properties.key} from theme.properties
    .replace(/\$\{properties\.([A-Za-z0-9_]+)!'([^']*)'\}/g, (m, k, d) => props[k] ?? d)
    .replace(/\$\{properties\.([A-Za-z0-9_]+)\}/g, (m, k) => props[k] ?? '')
    .replace(/\$\{url\.resourcesPath\}/g, 'resources')
    .replace(/<#import [^>]+>/g, '')
    .replace(/<#--[\s\S]*?-->/g, '')
    .replace(/<@[^>]+\/>/g, '<a class="passkey-button" href="#">Sign in with Passkey</a>')
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



const THEMES_DIR = 'themes';

function readProperties(file) {
  const props = {};
  if (!fs.existsSync(file)) return props;
  for (const line of fs.readFileSync(file, 'utf8').split('\n')) {
    const m = line.match(/^\s*([^#!\s][^=]*?)\s*=\s*(.*)$/);
    if (m) props[m[1]] = m[2].trim();
  }
  return props;
}

// [child, parent, grandparent, ...] for themes that live in this repo.
// Keycloak's own themes (base, keycloak.v3) end the chain.
function themeChain(theme, type) {
  const chain = [];
  let name = theme;
  while (name && fs.existsSync(path.join(THEMES_DIR, name, type))) {
    const dir = path.join(THEMES_DIR, name, type);
    chain.push(dir);
    name = readProperties(path.join(dir, 'theme.properties')).parent;
  }
  return chain;
}

function processTemplates(chain) {
  // theme.properties: parent values first, child overrides
  const props = {};
  for (const dir of [...chain].reverse()) {
    Object.assign(props, readProperties(path.join(dir, 'theme.properties')));
  }
  const resolve = (name) => {
    for (const dir of chain) {
      const f = path.join(dir, name);
      if (fs.existsSync(f)) return fs.readFileSync(f, 'utf8');
    }
    return '';
  };
  const templates = {};
  for (const dir of [...chain].reverse()) {
    for (const file of fs.readdirSync(dir)) {
      if (!file.endsWith('.ftl')) continue;
      const content = fs.readFileSync(path.join(dir, file), 'utf8');
      // skip partials such as brand-vars.ftl, only full pages get a tab
      if (!content.includes('<html')) continue;
      templates[file] = processFtl(content, props, resolve);
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
  const outputDir = 'preview-build';
  fs.mkdirSync(outputDir, { recursive: true });

  const themes = fs.readdirSync(THEMES_DIR)
    .filter((t) => fs.existsSync(path.join(THEMES_DIR, t, 'login')))
    .sort();

  for (const theme of themes) {
    const chain = themeChain(theme, 'login');
    const themeOut = path.join(outputDir, theme);
    fs.mkdirSync(themeOut, { recursive: true });
    // parent resources first so the child's files win
    for (const dir of [...chain].reverse()) {
      copyResources(path.join(dir, 'resources'), themeOut);
    }
    const templates = processTemplates(chain);
    if (Object.keys(templates).length === 0) {
      console.error('No templates found for theme', theme);
      process.exitCode = 1;
      continue;
    }
    createPreview(templates, path.join(themeOut, 'index.html'));
  }

  const list = themes.map((t) => `<li><a href="${t}/index.html">${t}</a></li>`).join('\n');
  fs.writeFileSync(path.join(outputDir, 'index.html'),
    `<!DOCTYPE html><html><head><meta charset="utf-8"><title>Theme previews</title></head>` +
    `<body style="font-family: system-ui, sans-serif; padding: 2rem"><h1>Keycloak theme previews</h1><ul>${list}</ul></body></html>`);
  console.log('Preview created successfully!');
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