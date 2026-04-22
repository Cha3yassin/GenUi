import os

def fix_flutter_3_13_compat():
    base_dir = r"C:\Users\ZBook\Desktop\projetGenUi\GenUi\flutter-frontend\lib"
    
    replacements_made = 0
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = content.replace('.withValues(alpha: ', '.withOpacity(')
                new_content = new_content.replace('CardThemeData(', 'CardTheme(')
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    replacements_made += 1
                    print(f"Fixed: {file}")
                    
    print(f"All done! {replacements_made} files fixed.")

if __name__ == "__main__":
    fix_flutter_3_13_compat()
