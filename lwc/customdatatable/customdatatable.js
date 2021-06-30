import LightningDatatable from 'lightning/datatable';
import DatatablePicklistTemplate from './picklistTemplate.html';
import LookupTemplate from './lookupTemplate.html';

export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: DatatablePicklistTemplate,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        },
        lookup: {
            template: LookupTemplate,
            typeAttributes: ['uniqueId', 'objectType', 'icon', 'label', 'displayFields', 'displayFormat', 'placeholder', 'filters', 'valueId', 'fieldName', 'additionalSearchField']
        }
    };
}