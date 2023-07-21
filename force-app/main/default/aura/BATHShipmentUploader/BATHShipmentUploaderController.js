({
    onTableImport: function (cmp, evt, helper) {
        helper.disableExcelInput(cmp,evt);
        helper.importTableAndThrowEvent(cmp, evt, helper);
    }
})