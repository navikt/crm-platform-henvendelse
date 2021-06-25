/**
 * Applicaiton specific Domain base class, customise fflib_SObjectSelector and add common behaviour
 **/
public inherited sharing abstract class CRM_ApiSelector extends fflib_SObjectSelector {
    public CRM_ApiSelector() {
        this(false);
    }

    public CRM_ApiSelector(Boolean includeFieldSetFields) {
        // Disable the base class read security checking in preference to explicit checking elsewhere
        this(includeFieldSetFields, false, false);
    }

    public CRM_ApiSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        // Disable sorting of selected fields to aid debugging (performance optimisation)
        super(includeFieldSetFields, enforceCRUD, enforceFLS, false);
    }
}
