#!/bin/bash
echo "=== Terraform File Diagnostic ==="

cd /var/www/html/Project/python/insight-agent/terraform

echo "1. File sizes:"
ls -la *.tf

echo -e "\n2. Checking for required blocks:"
echo "main.tf:"
grep -n "terraform\|provider\|resource" main.tf | head -10 || echo "No blocks found"

echo -e "\n3. Testing Terraform syntax:"
if terraform init -backend=false 2>&1 | grep -i "error\|invalid"; then
    echo "❌ Terraform initialization failed"
    terraform init -backend=false 2>&1 | tail -20
else
    echo "✅ Terraform initialized successfully"
fi

echo -e "\n4. Validating:"
terraform validate 2>&1
