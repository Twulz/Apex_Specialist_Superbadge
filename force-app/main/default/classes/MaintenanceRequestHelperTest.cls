@isTest
public class MaintenanceRequestHelperTest {

    @TestSetup
    static void makeData()  {
        Vehicle__c vehicle1 = new Vehicle__c(
            Name = 'Winnebago'
        );
        insert vehicle1;

        Product2 equipment1 = new Product2(
            Name = 'Motor',
            Maintenance_Cycle__c = 1
        );
        insert equipment1;
    }

    @isTest
    public static void autoCreateNewMaintReq() {

        test.startTest();

        Vehicle__c vehicle1 = [SELECT Id FROM Vehicle__c WHERE Name = 'Winnebago' LIMIT 1];
        Product2 equipment1 = [SELECT Id, Maintenance_Cycle__c FROM Product2 WHERE Name = 'Motor' LIMIT 1];

        List<Case> initialMaintReqs = [SELECT Id, Status FROM Case WHERE Vehicle__c = :vehicle1.Id AND Equipment__c = :equipment1.Id];

        Case originalMaintReq = new Case(
            Type = 'Repair',
            Status = 'New',
            Origin = 'Web',
            Vehicle__c = vehicle1.Id,
            Equipment__c = equipment1.Id
        );
        insert originalMaintReq;

        List<Case> createdMaintReqs = [SELECT Id, Status FROM Case WHERE Vehicle__c = :vehicle1.Id AND Equipment__c = :equipment1.Id];

        System.assertEquals(initialMaintReqs.size()+1, createdMaintReqs.size(), 'More than one maintenance request was created');

        createdMaintReqs[0].Status = 'Closed';
        update createdMaintReqs;

        List<Case> finalMaintReqs = [SELECT Id, Status, Equipment__c, Vehicle__c, Type, Subject, Date_Reported__c, Date_Due__c FROM Case WHERE Vehicle__c = :vehicle1.Id AND Equipment__c = :equipment1.Id];

        test.stopTest();

        System.assertEquals(initialMaintReqs.size()+2, finalMaintReqs.size(), 'One maintenance request was not created');
        for (Case maintReq : finalMaintReqs) {
            if (maintReq.Subject == 'Maintain Part') {
                System.assertEquals(equipment1.Id, maintReq.Equipment__c, 'Request isn\'t assigned to original equipment');
                System.assertEquals(vehicle1.Id, maintReq.Vehicle__c, 'Request isn\'t assigned to original vehicle');
                System.assertEquals('Routine Maintenance', maintReq.Type, 'Request isn\'t Routine Maintenance type');
                System.assertNotEquals(null, maintReq.Subject, 'Request subject is null');
                System.assertEquals(Date.today(), maintReq.Date_Reported__c, 'Request wasn\'t reported today');
                System.assertEquals(Date.today()+(Integer)equipment1.Maintenance_Cycle__c, maintReq.Date_Due__c, 'Request due date is incorrect');
            }
        }
    }

    @isTest
    public static void dontCreateNewMaintReq() {

        test.startTest();

        Vehicle__c vehicle1 = [SELECT Id FROM Vehicle__c WHERE Name = 'Winnebago' LIMIT 1];
        Product2 equipment1 = [SELECT Id, Maintenance_Cycle__c FROM Product2 WHERE Name = 'Motor' LIMIT 1];

        List<Case> initialMaintReqs = [SELECT Id, Status FROM Case WHERE Vehicle__c = :vehicle1.Id AND Equipment__c = :equipment1.Id];

        Case originalMaintReq = new Case(
            Type = 'Other',
            Status = 'New',
            Origin = 'Web',
            Vehicle__c = vehicle1.Id,
            Equipment__c = equipment1.Id
        );
        insert originalMaintReq;

        List<Case> createdMaintReqs = [SELECT Id, Status FROM Case WHERE Vehicle__c = :vehicle1.Id AND Equipment__c = :equipment1.Id];

        System.assertEquals(initialMaintReqs.size()+1, createdMaintReqs.size(), 'More than one maintenance request was created');

        createdMaintReqs[0].Status = 'Closed';
        update createdMaintReqs;

        List<Case> finalMaintReqs = [SELECT Id, Status, Equipment__c, Vehicle__c, Type, Subject, Date_Reported__c, Date_Due__c FROM Case WHERE Vehicle__c = :vehicle1.Id AND Equipment__c = :equipment1.Id];

        test.stopTest();

        System.assertEquals(initialMaintReqs.size()+1, finalMaintReqs.size(), 'Another maintenance request was created');
    }

    @isTest 
    public static void bulkMaintReqTest() {

        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        List<Product2> equipment = new List<Product2>();
        List<Case> maintReqs = new List<Case>();
        List<Id> vehicleIds = new List<Id>();

        for (Integer i=0; i<300; i++) {
            vehicles.add(new Vehicle__c(Name = 'Vehicle '+i));
            equipment.add(new Product2(Name = 'Equipment '+i, Maintenance_Cycle__c=5));
        }

        test.startTest();

        insert vehicles;
        insert equipment;

        for (Integer i=0; i<150; i++) {
            maintReqs.add(new Case(
                Subject = 'Bulk Test',
                Type = 'Repair',
                Status = 'New',
                Origin = 'Web',
                Vehicle__c = vehicles[i].Id,
                Equipment__c = equipment[i].Id
            ));
            vehicleIds.add(vehicles[i].Id);
        }
        for (Integer i=150; i<300; i++) {
            maintReqs.add(new Case(
                Subject = 'Bulk Test',
                Type = 'Routine Maintenance',
                Status = 'New',
                Origin = 'Web',
                Vehicle__c = vehicles[i].Id,
                Equipment__c = equipment[i].Id
            ));
            vehicleIds.add(vehicles[i].Id);
        }
        insert maintReqs;

        List<Case> insertedMaintReqs = [SELECT Id, Status FROM Case WHERE Subject = 'Bulk Test'];

        for (Case maintReq : insertedMaintReqs) {
            maintReq.Status = 'Closed';
        }
        update insertedMaintReqs;

        List<Case> autoAddMaintReqs = [SELECT Id, Status, Equipment__c, Vehicle__c, Type, Subject, Date_Reported__c, Date_Due__c FROM Case WHERE Vehicle__c IN :vehicleIds];

        test.stopTest();

        for (Case maintReq : autoAddMaintReqs) {
            if (maintReq.Subject == 'Maintain Part') {
                System.assertEquals('Routine Maintenance', maintReq.Type, 'Request isn\'t Routine Maintenance type');
                System.assertNotEquals(null, maintReq.Subject, 'Request subject is null');
                System.assertEquals(Date.today(), maintReq.Date_Reported__c, 'Request wasn\'t reported today');
                System.assertEquals(Date.today()+5, maintReq.Date_Due__c, 'Request due date is incorrect');
            }
        }
    }

}
