"""Run inside the backend container; outputs configuration only, never business tables."""
import json
import os
import frappe

os.chdir('/home/frappe/frappe-bench/sites')
frappe.init(site='erp.localhost')
frappe.connect()

OMIT = {'creation', 'modified', 'modified_by', 'owner', '_user_tags', '_comments', '_assign', '_liked_by'}

def clean(value):
    if isinstance(value, dict):
        return {k: clean(v) for k, v in value.items() if k not in OMIT}
    if isinstance(value, list):
        return [clean(v) for v in value]
    return value

result = {}
for doctype, filters in [
    ('Workspace', {'name': 'Equipment Management'}),
    ('Custom HTML Block', {}),
    ('Client Script', {}),
    ('Server Script', {}),
    ('Custom Field', {}),
    ('Property Setter', {}),
    ('Translation', {}),
]:
    names = frappe.get_all(doctype, filters=filters, pluck='name', order_by='name')
    result[doctype] = [clean(frappe.get_doc(doctype, name).as_dict()) for name in names]
print(json.dumps(result, ensure_ascii=False, indent=2, default=str, sort_keys=True))
frappe.destroy()
