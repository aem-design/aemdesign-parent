AEM.Design Principles
=====================

This chapter detail topics that will help you to get most out of AEM.Design.

Please try to lean AEM.Design before you start attempting to implement new patterns that you have used previously.

* Content First, Structure later, maybe (maybe not)
This is a fundamental of development for CQ please learn this first do not assume that configs are content.
Everything needs to be authorable easily.
Some notable examples what defines Structure
    * OSGI Service Code is structure, this needs to be very selective to ensure that services kept to a minimum and are very generic
    * Path Selectors are structure, this should be used very carefully as it will impact whole system and will be east DDOS target if not controlled properly, consider using Resource Type selectors, although they also have drawback as you do not know when looking at resource if its an actual component, see Resource Selectors
    * Resource Selectors for Servlets are easy to implement but can cause confusion when determining what code applies to your resource
    * Hardcoded string are not authorable
    * Markup in Code is not authorable
    * Specific Content structures that can only be edited using CRX-DE
    * Configuration patterns where there are no End User UI to update configs
* Tools for authoring content, these need to be considered for every component
Following paterns exist to manage all content that can be managed by authors
    * Dictionaries using i18n - used for creating labels and constants at component group level
    * Tags with metadata - used to manage all component inputs, please review Style, Accessibility and Analytics tabs that apply to call components
    * Content Fragments - used for creating single use components clusters that authors can place on pages
    * Embed Source - used to for creating single use components
    * Design Importer - used to manage all Web Apps and complex components build independent in Prototype project.
    * Cloud Configs - used to manage all front end integration configs
    * Template Editor - used to manage all components in templates pages and their default configurations
    * OSGI Config Manager - used to manage only SYSTEM settings that impact Servlet and component operation, these usualy have deep system impacts and must be considered carefully
* Component Patterns (that you would not have seen any where before)
    * Variants - component templates that appear on a page, this allow quick toggle to component presentation based on same data in the component, avoid making components based on different layouts but similar data attributes
    * Badges - component templates that are used in Lists, this applies primarily to Page Details and Page List combination components, Page List component looks for Page Details in each page and renders the badge from that Page Details component.
    * Tags As Config - usage of tags to allow configuration of components, this allow very dynamic styling of components, also removes need to hardcode CSS into templates, primary application
        * Styles - manage all styling and functionality divided into following categories, check default structure set in ```DEFAULT_FIELDS_STYLE```
            * Theme - themes to be applied to component, added to ```class```
            * Modifier - modifiers to add to component, added to ```class``` after theme
            * Chevron - icons to use for component chevron use, added to ```class``` after modifier
            * Icon - icons to use for component icon use, added to ```class``` after chevron
            * Module - attach behaviour modules to component, added to ```data-module```
        * Accessibility - manage accessibility configuration
        * Analytics - manage events to be triggered for a component
* Naming Conventions
Following is a list of know naming conventions
    * Component name suffix ```-details``` reserved for details components that contain metadata that can be added to pages
    * Component name suffix ```list``` reserved to describe component that output Lists
* Component Structure
    * Component in Apps must go into Component Category
* Best Components to start learning AEM.Design
    * Text - Easy, demonstrates variant, dialogs
    * Article - Easy, demonstrates containers
    * Breadcrumb - Easy, demonstrates metadata structures
    * Content Block - Moderate, demonstrates metadata structures
    * Download - Moderate, demonstrated empty variants, interaction with assets, i18n usage, thumbnails handling, image rendtions
    * Image - Hard, demonstrated empty variants, interaction with assets, i18n usage, thumbnails handling, image rendtions
    * Page Details - Hard, demonstrated Badges, Badge configuration
    * Page List - Hard, uses super type of List component only requires specifying which "Details" component to target, demonstrated Badge override configurations
* Component Code Conventions
    * Component Fields definition, all component fields need to be read into ```componentProperties``` map before its passed to templates
    * Component Fields helper collection, all component have similar field array that aids in reading all fields in one operation from the component node
    ```
    //COMPONENT STYLES
    // {
    //   1 required - property name,
    //   2 required - default value,
    //   3 optional - name of component attribute to add value into
    //   4 optional - canonical name of class for handling multivalues, String or Tag
    // }
    Object[][] componentFields = {
            {"text", ""},
            {FIELD_VARIANT, DEFAULT_VARIANT}
    };
    ```
    Structure of the array is as follows
        * Field 1 = property name to read from component node
        * Field 2 = default value to use if not value defined in node AND style does not have one defined, this is absolute fall back
        * Field 3 = name of the data attribute to add the value into, this will be the key for the attribute added to component attributes
        * Field 4 = this is special indicator how to handle the value being passed, following is effect for classes
            * String[] - will join all string separated with comma
            * Tag.class.getCanonicalName() -  will get Tags and join Values of the tags into space delimited list, example:
                ```
                {FIELD_STYLE_COMPONENT_THEME, new String[]{},"class", Tag.class.getCanonicalName()},
                {FIELD_STYLE_COMPONENT_MODIFIERS, new String[]{},"class", Tag.class.getCanonicalName()},
                {FIELD_STYLE_COMPONENT_MODULES, new String[]{},"data-module", Tag.class.getCanonicalName()},
                {FIELD_STYLE_COMPONENT_CHEVRON, new String[]{},"class", Tag.class.getCanonicalName()},
                {FIELD_STYLE_COMPONENT_ICON, new String[]{},"class", Tag.class.getCanonicalName()},
                ```
    * ComponentProperties helper class allows single place to aggregate all of your component attributes, it MUST contains all of the required data for presentation, no other reads from nodes must occur in templates
    ```
    ComponentProperties componentProperties = getComponentProperties(
            pageContext,
            componentFields,
            DEFAULT_FIELDS_STYLE,
            DEFAULT_FIELDS_ACCESSIBILITY,
            DEFAULT_FIELDS_DETAILS_OPTIONS);
    ```
* Testing is a MUST
    * All code that is compiled into JAR MUST have Unit Tests, Functional Test don't count, Unit Test is to test your code before its compiled. This is to ensure you have test and you avoid writing code unless you have good reason to this in that case you will write tests
    * All components must have Showcase pages and base Automated Tests, there are template that exist start with those