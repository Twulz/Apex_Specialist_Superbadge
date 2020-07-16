public with sharing class MaintenanceRequestHelper {


    
    public static void updateWorkOrders(List<Case> inputRequests) {

        List<Case> maintRequests = [SELECT Id, Type, Status, Vehicle__c, Equipment__c, Equipment__r.Maintenance_Cycle__c FROM Case WHERE Id IN :inputRequests];

        List<Case> newMaintReqs = new List<Case>();

        for (Case maintReq : maintRequests) {
            if (((maintReq.type == 'Repair') || (maintReq.type == 'Routine Maintenance')) && maintReq.status == 'Closed') {
                newMaintReqs.add(new Case (
                    Vehicle__c = maintReq.Vehicle__c,
                    Equipment__c = maintReq.Equipment__c,
                    Type = 'Routine Maintenance',
                    Subject = 'Maintain Part',
                    Date_Reported__c = Date.today(),
                    Date_Due__c = Date.today().addDays(Integer.valueOf(maintReq.Equipment__r.Maintenance_Cycle__c))
                ));
            }
        }

        insert newMaintReqs;
        
    }        
    
}