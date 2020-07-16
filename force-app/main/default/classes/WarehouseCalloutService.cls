public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    @future(callout=true)
    public static void runWarehouseEquipmentSync() {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        List<Product2> upsertingEquipment = new List<Product2>();

        if (response.getStatusCode() == 200) {

            List<Object> equipment = (List<Object>) JSON.deserializeUntyped(response.getBody());

            System.debug(LoggingLevel.DEBUG, 'Received the following Equipment:');
            for (Object equipment_piece: equipment) {

                Map<String,Object> equipParamToValue = (Map<String,Object>) equipment_piece;

                // Print equipment to console for debugging
                System.debug(LoggingLevel.DEBUG, 'START NEW EQUIPMENT');
                for (String param : equipParamToValue.keySet()) {
                    System.debug(LoggingLevel.DEBUG, param + ' ' + equipParamToValue.get(param));
                }

                // Add equipment to be upserted
                upsertingEquipment.add(new Product2(
                    ExternalId = (String)equipParamToValue.get('_id'),
                    Replacement_Part__c = (Boolean)equipParamToValue.get('replacement'),
                    Current_Inventory__c = (Decimal)equipParamToValue.get('quantity'),
                    Name = (String)equipParamToValue.get('name'),
                    Maintenance_Cycle__c = (Decimal)equipParamToValue.get('maintenanceperiod'),
                    Lifespan_Months__c = (Decimal)equipParamToValue.get('lifespan'),
                    Cost__c = (Decimal)equipParamToValue.get('cost'),
                    Warehouse_SKU__c = (String)equipParamToValue.get('sku')
                ));
            }

            // Upsert
            upsert upsertingEquipment;

        } else {
            System.debug(LoggingLevel.ERROR, 'Sync unsuccessful, response code: ' + response.getStatusCode());
            System.debug(LoggingLevel.ERROR, 'Error message: ' + response.getStatus());
        }
    }
}