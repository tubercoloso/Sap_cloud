@EndUserText.label: 'ZFI_CONTI_PROV'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_ZfiContiProv
  as select from zfi_conti_prov
  association        to parent ZI_ZfiContiProv_S     as _ZfiContiProvAll on  $projection.SingletonID = _ZfiContiProvAll.SingletonID
  association [0..1] to I_CompanyCode                as _CompanyCode     on  $projection.Bukrs = _CompanyCode.CompanyCode
  association [0..1] to I_GlAccountTextInCompanycode as _GLAccount       on  _GLAccount.GLAccount   = $projection.Hkont
                                                                         and _GLAccount.CompanyCode = $projection.Bukrs
                                                                         and _GLAccount.Language    = $session.system_language
{

      @ObjectModel.text.element:  [ 'DescriptionBukrs' ]
  key bukrs                        as Bukrs,
      @ObjectModel.text.element:  [ 'DescriptionHkont' ]
  key hkont                        as Hkont,

      _CompanyCode.CompanyCodeName as DescriptionBukrs, // z
      _GLAccount.GLAccountName     as DescriptionHkont, // z
      @Consumption.hidden: true
      1                            as SingletonID,
      _ZfiContiProvAll
}
