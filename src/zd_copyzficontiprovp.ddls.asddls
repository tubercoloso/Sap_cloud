@EndUserText.label: 'Copy ZFI_CONTI_PROV'
define abstract entity ZD_CopyZfiContiProvP
{
  @EndUserText.label: 'New Company Code'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Bukrs' )
  Bukrs : bukrs;
  
  @EndUserText.label: 'New G/L Account'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Hkont' )
  Hkont : hkont;
}
