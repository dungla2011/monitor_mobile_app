# GitHub Pages Setup Guide

## Overview
Hướng dẫn setup GitHub Pages để deploy Flutter Web app tự động qua CI/CD.

## Repository Settings Required

### 1. Enable GitHub Pages
1. Vào **Settings** > **Pages**
2. **Source**: Deploy from a branch hoặc **GitHub Actions** (recommended)
3. Nếu chọn GitHub Actions: Select "GitHub Actions" từ dropdown

### 2. Permissions Setup
Repository cần có permissions sau:
- **Actions**: Read and write permissions
- **Pages**: Write permissions  
- **Contents**: Read permissions

#### Cách check/fix permissions:
1. **Settings** > **Actions** > **General**
2. **Workflow permissions**: Select "Read and write permissions"
3. Check "Allow GitHub Actions to create and approve pull requests"

### 3. Environment Protection (Optional)
1. **Settings** > **Environments**
2. Tạo environment tên `github-pages`
3. Add protection rules nếu cần

## CI/CD Workflow Explanation

### Current Setup
```yaml
permissions:
  contents: read
  pages: write
  id-token: write

environment:
  name: github-pages
  url: ${{ steps.deployment.outputs.page_url }}

steps:
  - name: Build web
    run: flutter build web --release
    
  - name: Setup Pages
    uses: actions/configure-pages@v4
    
  - name: Upload Pages artifact
    uses: actions/upload-pages-artifact@v3
    with:
      path: ./build/web
      
  - name: Deploy to GitHub Pages
    id: deployment
    uses: actions/deploy-pages@v4
```

### Key Changes từ v3 → v4
- ✅ **New**: Sử dụng `actions/configure-pages@v4`
- ✅ **New**: Sử dụng `actions/upload-pages-artifact@v3`
- ✅ **New**: Sử dụng `actions/deploy-pages@v4`
- ❌ **Old**: `peaceiris/actions-gh-pages@v3` (deprecated approach)

## Common Issues & Solutions

### 1. Permission Denied (403)
**Error**: `remote: Permission to user/repo.git denied to github-actions[bot]`

**Solutions**:
- ✅ Add `permissions` section to workflow
- ✅ Enable "Read and write permissions" trong repo settings
- ✅ Sử dụng GitHub Actions v4 thay vì peaceiris/actions-gh-pages

### 2. GITHUB_TOKEN Issues
**Error**: `Error: Input required and not supplied: token`

**Solutions**:
- ✅ Không cần `github_token` với Actions v4
- ✅ Permissions được handle tự động qua `permissions` section

### 3. Branch Protection
**Error**: Branch protection rules prevent deployment

**Solutions**:
- Disable branch protection cho `gh-pages` branch
- Hoặc add GitHub Actions bot vào bypass list

### 4. Build Path Issues
**Error**: No files found in publish directory

**Solutions**:
```yaml
- name: Build web
  run: flutter build web --release --web-renderer html
  
- name: Upload Pages artifact
  uses: actions/upload-pages-artifact@v3
  with:
    path: ./build/web  # Đảm bảo path đúng
```

## Verification Steps

### 1. Check Workflow
- Workflow runs successfully ✅
- Deploy job completes ✅
- GitHub Pages URL accessible ✅

### 2. Check Pages Settings
- **Settings** > **Pages**
- Source: "Deploy from a branch" hoặc "GitHub Actions"
- Custom domain (nếu có)

### 3. Access Deployed App
- URL format: `https://username.github.io/repository-name/`
- Ví dụ: `https://dungla2011.github.io/monitor_mobile_app/`

## Flutter Web Specific

### Base Href Setup
Nếu app không load đúng, có thể cần set base href:

```yaml
- name: Build web
  run: flutter build web --release --base-href "/repository-name/"
```

### Web Renderer
Có thể cần specify web renderer:

```yaml
- name: Build web  
  run: flutter build web --release --web-renderer html
```

## Troubleshooting Commands

```bash
# Local build test
flutter build web --release

# Check build output
ls -la build/web/

# Test local server
cd build/web && python -m http.server 8000
```

## Security Notes

- ✅ Sử dụng `GITHUB_TOKEN` (tự động provided)
- ❌ Không commit personal access tokens
- ✅ Permissions được scope minimal cần thiết
- ✅ Environment protection cho production

## Status Check

Sau khi setup:
- [ ] Repository permissions enabled
- [ ] GitHub Pages source configured  
- [ ] Workflow runs successfully
- [ ] App accessible tại GitHub Pages URL
- [ ] No console errors trong deployed app
