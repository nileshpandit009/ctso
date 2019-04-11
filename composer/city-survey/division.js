
/**
 * ProperyDivision transaction
 * @param {gov.citysurvey.PropertyDivision} propertyDivision
 * @transaction
 */
async function propertyDivision(tx) {
    let totalArea = 0.0;
    tx.stakeholders.forEach(element => {
        totalArea += element.shareArea;
    });
    if (totalArea < tx.property.propertyArea || totalArea > tx.property.propertyArea) {
        throw new Error("Area shares wrong: total of all shares is more than actual area");
    } else {
        let owners = tx.property.propertyOwners;
        let assetRegistry = await getAssetRegistry('gov.citysurvey.PropertyPlot');
        let factory = await getFactory();
        let addArray = new Array();

        // make the shares
        tx.stakeholders.forEach(element => {
            let plotId = tx.stakeholders.indexOf(element) + 1;
            let surveyId = tx.property.surveyNum;
            let property = factory.newResource('gov.citysurvey', 'Property', surveyId.toString());
            let newPlot = factory.newResource('gov.citysurvey', 'PropertyPlot', plotId.toString());

            newPlot.plotNum = plotId.toString();
            newPlot.plotOwners = owners.splice(owners.indexOf(element), owners.indexOf(element));
            newPlot.plotArea = element.shareArea;

            property.surveyNum = surveyId.toString();
            // tx.property.propertyPlots.plotNum = tx.stakeholders.indexOf(element) + 1;
            // tx.property.propertyPlots.plotOwners = owners.splice(owners.indexOf(element), owners.indexOf(element));
            // tx.property.propertyPlots.plotArea = tx.stakeholders.shareArea;
            property.propertyType = tx.property.propertyType;

            addArray.push(newPlot);
        });
        await assetRegistry.addAll(addArray);
    }
}

