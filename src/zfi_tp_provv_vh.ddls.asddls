@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZFI_TP_PROVV_VH as select from zfi_tp_provv 
{
    @EndUserText.label: 'ID'
    key icon_id as IconId,
    @EndUserText.label: 'Icon Url'
    icon_uri as IconUri,
    @Search.defaultSearchElement: true
    description as Description
}
