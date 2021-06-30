import { LightningElement, api, track } from 'lwc';
import getColumns from '@salesforce/apex/DatatableController.getColumns';
import getTypeAttributesForAddExistingRecord from '@salesforce/apex/DatatableController.getTypeAttributesForAddExistingRecord';
import getRecord from '@salesforce/apex/DatatableController.getRecord';

export default class Demo extends LightningElement {
    constructor() {
        super();
    }

    @api tableData;
    @api allowAddRows;
    @api allowAddExistingRecord;
    @api allowRemoveRecord;
    @api outputTableData;
    @api tableColumns;
    @api tableLabel;
    @track draftValues = [];
    @track data = [];

    lastSavedData = [];

    columns;
    addExistingRecordTypeAttributes;
    addExistingRecordId;

    connectedCallback() {
        this.data = this.tableData;
        this.outputTableData = this.data;

        this.lastSavedData = JSON.parse(JSON.stringify(this.data));

        getTypeAttributesForAddExistingRecord({ sObjectId: this.tableData[0].Id })
            .then(result => {
                this.addExistingRecordTypeAttributes = JSON.parse(result);

            })
            .catch(error => {
                console.error(error);
            });

        getColumns({ commaSeperatedColumnApiNames: this.tableColumns, sObjectId: this.tableData[0].Id })
            .then(result => {
                this.columns = JSON.parse(result);

                if (this.allowRemoveRecord) {
                    const actions = [
                        { label: 'Remove', name: 'remove' }
                    ];
                    this.columns.push({ label: 'Remove Row', type: 'action', fixedWidth: 100, typeAttributes: { rowActions: actions, menuAlignment: 'left' } })
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    // only a single action available - remove
    handleRowAction(event) {
        this.data = JSON.parse(JSON.stringify(this.data));
        this.outputTableData = JSON.parse(JSON.stringify(this.outputTableData));

        const row = event.detail.row;

        console.log(JSON.parse(JSON.stringify(row)))

        const recordIndex = this.data.findIndex(x => x.Id == row.Id);
        this.data.splice(recordIndex, 1);
        this.outputTableData.splice(recordIndex, 1);

    }

    handlePicklistValueChange(event) {
        event.stopPropagation();
        // type: { context: context, value: value, label: label, name: name }
        const dataRecieved = event.detail.data;
        this.data = JSON.parse(JSON.stringify(this.data));
        this.lastSavedData = JSON.parse(JSON.stringify(this.data));

        const index = this.data.findIndex(x => x.Id == dataRecieved.context);
        this.data[index][dataRecieved.name] = dataRecieved.value;
        const draftValue = { Id: dataRecieved.context, [dataRecieved.name]: dataRecieved.value };
        this.updateDraftValues(draftValue);
    }

    updateDraftValues(updatedItem) {
        this.draftValues = JSON.parse(JSON.stringify(this.draftValues));
        // check if the item exists in the draft values and add it if it doesn't
        const draftValueItemIndex = this.draftValues.map(x => x.Id).indexOf(updatedItem.Id);
        if (draftValueItemIndex == -1) {
            this.draftValues = [...this.draftValues, updatedItem];
            return;
        }
        else {
            const draftValueItem = JSON.parse(JSON.stringify(this.draftValues))[draftValueItemIndex];
            for (let field in updatedItem) {
                draftValueItem[field] = updatedItem[field];
            }
            this.draftValues[draftValueItemIndex] = draftValueItem;
        }
    };

    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }

    handleLookupSelection(event) {
        this.data = JSON.parse(JSON.stringify(this.data));
        this.lastSavedData = JSON.parse(JSON.stringify(this.data));
        // type: { selectedId, key, fieldName }
        const dataRecieved = event.detail.data;

        const index = this.data.findIndex(x => x.Id == dataRecieved.key);
        this.data[index][dataRecieved.fieldName] = dataRecieved.selectedId;
        const draftValue = { Id: dataRecieved.key, value: dataRecieved.selectedId };
        this.updateDraftValues(draftValue);
    }

    handleAddExistingRowSelection(event) {
        this.addExistingRecordId = event.detail.data.selectedId;
    }

    handleSave(event) {
        console.log(JSON.parse(JSON.stringify(this.draftValues)))
        this.outputTableData = JSON.parse(JSON.stringify(this.outputTableData));
        this.data = JSON.parse(JSON.stringify(this.data));
        this.lastSavedData = JSON.parse(JSON.stringify(this.data));

        this.draftValues.forEach(draftValue => {
            const index = this.outputTableData.findIndex(x => x.Id == draftValue.Id);

            // go through and update each property apart from the ID
            for (let [key, value] of Object.entries(draftValue)) {
                if (key == 'Id') {
                    continue;
                }
                this.outputTableData[index][key] = value;
                this.data[index][key] = value;
            }
        });

        this.draftValues = [];
    }

    addRow(event) {
        const currentData = JSON.parse(JSON.stringify(this.data));
        const skeletonObject = skeleton(currentData[0], false);

        skeletonObject.Id = getPlaceholderId();

        this.data = JSON.parse(JSON.stringify(this.data)).concat([skeletonObject]);
        this.outputTableData = this.outputTableData.concat([skeletonObject]);
        this.lastSavedData = JSON.parse(JSON.stringify(this.data));

        console.log(JSON.parse(JSON.stringify(this.outputTableData)))
    }

    handleClickAddExistingRow(event) {
        event.preventDefault();
        event.stopPropagation();
        this.template.querySelector('c-modal').toggleModal();
    }

    modalSaveHandler2 = (event) => {

        event.stopPropagation();
        this.handleClickAddExistingRow(event);

        getRecord({ selectedId: this.addExistingRecordId })
            .then(result => {
                const newRecord = JSON.parse(result);

                this.data = JSON.parse(JSON.stringify(this.data));
                this.outputTableData = JSON.parse(JSON.stringify(this.outputTableData));

                this.data.push(newRecord);
                this.outputTableData.push(newRecord);
            })
            .catch(error => {
                console.error(error);
            });
    };

}

function skeleton(source, isArray) {
    var o = Array.isArray(source) ? [] : {};
    for (var key in source) {
        if (source.hasOwnProperty(key)) {
            var t = typeof source[key];
            o[key] = t == 'object' ? skeleton(source[key]) : { string: '', number: 0, boolean: false }[t];
        }
    }
    if (Object.keys(o).length == 0) {
        o = null;
    }
    return o;
}

function getPlaceholderId(length) {
    let r = Math.random().toString(36).substring(7);
    return `placeholder-${r}`;
}