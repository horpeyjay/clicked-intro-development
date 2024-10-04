trigger BillTrigger on Bill__c (before insert, after insert) {
    
    if (Trigger.isInsert){
        if(Trigger.isBefore){
            BillHelperClass.billAccountFieldValidation(Trigger.new);
            BillHelperClass.invoiceAutopopulate(Trigger.new);
        }else if(Trigger.isAfter){
            BillHelperClass.createOpps4Bill(Trigger.new);
        }
    }
}
