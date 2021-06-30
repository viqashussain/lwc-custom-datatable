
# lwc-custom-datatable

Salesforce Lightning Web Component for a native Salesforce Datatable that can be used in Lightning Flows.

**Features include:**
- Ability to edit all columns apart from the first column.
- Use and edit picklist values.
- Lookup fields supported.
- Ability to add new empty rows.
- Ability to add new existing rows (e.g. add an account to the already existing list of accounts in the datatable). Note: the types of new records being added must match the original list.
- Delete rows from the datatable.

**Components**
**Apex:**
- DatatableController - used to retrieve meta data such as column definitions and lookup records from Salesforce.
- LookupController - used to return records used in lookup fields.

**Lwc:**
 - customdatatable - the main custom datatable component that you will use when injecting into other components. This basically serves as a placeholder for using lookup and picklist values in the datatable.
 - demo - this component can be used in Lightning Flows (although you should probably rename it). This component has all the pre-built ability to save, edit, cancel, lookup etc.
 - datatablePicklist - component to render picklists in the datatable.
 - lookupLwc - component to render lookups in the datatable.
 - stencilLwc - component to render each lookup item when using a lookup field.
 - modal - a popup component used when you want to add an existing record to the table.

**Static Resources**:
CustomDataTable - custom styling for the custom datatable.
