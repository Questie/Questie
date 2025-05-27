import os

# Define directories to search
directories = ['.', './Database', './Modules']
# Initialize mappings
file_to_module = {}
module_imports = {}

# Step 1: Scan for module creation and imports
for directory in directories:
    for filename in os.listdir(directory):
        if filename.endswith('.lua'):
            filepath = os.path.join(directory, filename)
            with open(filepath, 'r') as file:
                for line in file:
                    if "QuestieLoader:CreateModule" in line:
                        module_name = line.split('"')[1]  # Assuming module name is in double quotes
                        file_to_module[filepath] = module_name
                        if module_name not in module_imports:
                            module_imports[module_name] = set()
                    elif "QuestieLoader:ImportModule" in line:
                        imported_module_name = line.split('"')[1]  # Assuming module name is in double quotes
                        # Map the file path to the module name if it exists
                        if filepath in file_to_module:
                            module_imports[file_to_module[filepath]].add(imported_module_name)

# Step 4: Generate Mermaid diagram syntax
mermaid_syntax = "graph TD\n"
for module, imports in module_imports.items():
    for imported_module in imports:
        # Create an edge from module to imported module
        mermaid_syntax += f"    {module} --> {imported_module}\n"

# Optionally, save the Mermaid syntax to a file
with open('module_diagram.mermaid', 'w') as diagram_file:
    diagram_file.write(mermaid_syntax)

# Print Mermaid syntax
print(mermaid_syntax)