/**
 * Applicaiton specific Domain base class, customise fflib_SObjectSelector and add common behaviour
 **/
public inherited sharing abstract class CRM_ApiSelector extends fflib_SObjectSelector {
    private static Exception simulatedException;

    /**
     * @description: Used in test context to enable exception simulation. All classes extending this will cast an exception when calling constructor.
     * @author Stian Ruud Schikora | 06-30-2021
     * @param ex
     **/
    @testVisible
    private static void simulateException(Exception ex) {
        simulatedException = ex;
    }

    public CRM_ApiSelector() {
        this(false);
    }

    public CRM_ApiSelector(Boolean includeFieldSetFields) {
        // Enabling base class enforcing FLS for ApiSelectors. All API consumers should be granted permission sets granting necessary access
        this(includeFieldSetFields, false, true);
    }

    public CRM_ApiSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        // Disable sorting of selected fields to aid debugging (performance optimisation)
        super(includeFieldSetFields, enforceCRUD, enforceFLS, false);
        if (simulatedException != null)
            throw simulatedException;
    }
}
