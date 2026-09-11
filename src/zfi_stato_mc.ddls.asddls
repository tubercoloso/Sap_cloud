@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Commission status'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_STATO_MC as select from zfi_stato
{
    key code as Code,
    description as Description
}
