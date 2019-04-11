/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

/**
 * Write your transction processor functions here
 */


/**
 * ProperyTransfer transaction
 * @param {gov.citysurvey.PropertyTransfer} propertyTransfer
 * @transaction
 */
async function propertyTransfer(tx) {
    const ns = 'gov.citysurvey';
    const assetRegistry = await getAssetRegistry(ns + '.Property');
    let factory = await getFactory();

    
    // Save the old value of the asset.
    const sellers = tx.property.propertyOwners;
    const oldArea = tx.property.propertyArea;

    // Update the asset with the new value.
    let buyers = tx.buyers;
    let newArea = tx.area;
    let newPropertyType = tx.newPropertyType;
    let isMortgaged = tx.property.mortgage.isMortgaged;
    let isLeased = tx.property.lease.isLeased;

    if (arraysEqual(sellers, tx.sellers) &&
        !tx.property.mortgage.isMortgaged &&
        !tx.property.lease.isLeased) {
        if (newArea == oldArea) {
                tx.property.propertyOwners = buyers;
                await assetRegistry.update(tx.property);
        } else {
            let newProperty = factory.newResource(ns, 'Property', tx.newSurveyNum);
            let newMortgage = factory.newConcept(ns, 'Mortgage');
            let newLease = factory.newConcept(ns, 'Lease');
            console.log(buyers);
            console.log(newArea);
            console.log(newPropertyType);
            newMortgage.isMortgaged = isMortgaged;
            newLease.isLeased = isLeased;
            newProperty.propertyOwners = buyers;
            newProperty.propertyArea = newArea;
            newProperty.propertyType = newPropertyType;
            newProperty.mortgage = newMortgage;
            newProperty.lease = newLease;

            await assetRegistry.add(newProperty);

            // Modify old values
            tx.property.propertyArea = tx.property.propertyArea - newArea;

            for (let i = 0; i < buyers.length; i++) {
                if (buyers.length < sellers.length) {
                    tx.property.propertyOwners = sellers.filter(buyer => !buyers.includes(buyer));
                }
            }
            await assetRegistry.update(tx.property);
        }

        // Emit an event for the modified asset.
        let event = getFactory().newEvent(ns, 'TransferEvent');
        event.property = tx.property;
        event.sellers = sellers;
        event.buyers = buyers;
        event.area = newArea;
        emit(event);

    } else {
        throw new Error("Suspicious Property");
    }
}


/**
 * ProperyMortgage transaction
 * @param {gov.citysurvey.PropertyMortgage} propertyMortgage
 * @transaction
 */
async function propertyMortgage(tx) {
    const ns = 'gov.citysurvey';
    const assetRegistry = await getAssetRegistry(ns + '.Property');

    let factory = await getFactory();

    const mortgage = tx.property.mortgage;
    
    let mortgageId = tx.mortgage.mortgageId;
    let isMortgaged = tx.mortgage.isMortgaged
    let lenders = tx.lenders;
    let borrowers = tx.borrowers;
    let mortgagePeriod = tx.mortgage.mortgagePeriod;
    let principalAmount = tx.mortgage.principal;
    let interestRate = tx.mortgage.interestRate;

    if (!mortgage.isMortgaged) {
        mortgage.mortgageId = mortgageId;
        mortgage.isMortgaged = isMortgaged;
        
        mortgage.mortgagePeriod = mortgagePeriod;
        mortgage.principal = principalAmount;
        mortgage.interestRate = interestRate;
    } else {
        throw new Error("This property is already mortgaged");
    }

    await assetRegistry.update(tx.property);


}

/**
 * ProperyLease transaction
 * @param {gov.citysurvey.PropertyLease} propertyLease
 * @transaction
 */
async function propertyLease(tx) {
    const ns = 'gov.citysurvey';
    const assetRegistry = await getAssetRegistry(ns + '.Property');

    const lease = tx.property.lease;

    let leaseId = tx.lease.leaseId;
    let isLeased = tx.lease.isLeased;
    let leaser = tx.leaser;
    let lessee = tx.lessee;
    let rent = tx.lease.rent;
    let leasePeriod = tx.lease.leasePeriod;

    if (!lease.isLeased) {
        lease.leaseId = leaseId;
        lease.isLeased = isLeased;

        lease.rent = rent;
        lease.leasePeriod = leasePeriod;
    } else {
        throw new Error("This property is already leased");
    }

    await assetRegistry.update(tx.property);

}




// Check if the arrays are equal.
function arraysEqual(arr1, arr2) {
    if (arr1 === arr2) return true;
    if (arr1 == null || arr2 == null) return false;
    if (arr1.length != arr2.length) return false;

    for (i in arr1) {
        if (arr1[i] !== arr2[i]) return false;
    }
    return true;
}