@isTest
private class WarehouseCalloutServiceTest {
    
    @isTest
    private static void testWarehouseSync() {

        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        test.StartTest();

        WarehouseCalloutService.runWarehouseEquipmentSync();

        List<Case> equipment = [SELECT Id FROM Case WHERE ExternalId IN ('12345', '54321');]

        test.StopTest();

        System.assertEquals(2, equipment.size(), 'Equipment was not inserted');

    }

}