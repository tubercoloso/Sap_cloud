//@AbapCatalog.viewEnhancementCategory: [#NONE]
//@AccessControl.authorizationCheck: #MANDATORY
//@EndUserText.label: 'View Entity for ZFI_PROVVIGIONI'
//@Analytics.dataCategory: #CUBE
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZFIMP001'
@EndUserText.label: 'View Entity for ZFI_PROVVIGIONI'


define root view entity ZI_PROVVIGIONI
  as select from zfi_provvigioni
  association to I_CompanyCode as _CompanyCode on $projection.CompanyCode  = _CompanyCode.CompanyCode
  association to I_Supplier    as _I_Supplier  on $projection.AgentCode    = _I_Supplier.Supplier
  association to I_Customer    as _I_Customer  on $projection.CustomerCode = _I_Customer.Customer
  association to ZI_ZfiTpProvv as _i_tipoprov  on $projection.ProvvType    = _i_tipoprov.IconId
{
  key id                              as Id,
      company_code                    as CompanyCode,
      _CompanyCode.CompanyCodeName    as CompanyCodeName,
      agent_code                      as AgentCode,
      _I_Supplier.OrganizationBPName1 as SupplierName,
      customer_code                   as CustomerCode,
      _I_Customer.CustomerName        as CustomerName,
      posting_date                    as PostingDate,
      accounting_document             as AccountingDocument,
      fiscal_year                     as FiscalYear,
      @Semantics.amount.currencyCode : 'ImportoProvvValIntCurrency'
      importo_provv_val_int           as ImportoProvvValInt,
      importo_provv_val_int_currency  as ImportoProvvValIntCurrency,
      @Semantics.amount.currencyCode : 'ImportoProvvValDocCurrency'
      importo_provv_val_doc           as ImportoProvvValDoc,
      importo_provv_val_doc_currency  as ImportoProvvValDocCurrency,
      @Semantics.amount.currencyCode : 'ImportoImponibileCurrency'
      importo_imponibile              as ImportoImponibile,
      importo_imponibile_currency     as ImportoImponibileCurrency,
      @Semantics.amount.currencyCode : 'ImportoImponibileCurInt'
      importo_imponibile_int          as ImportoImponibileInt,
      importo_imponibile_cur_int      as ImportoImponibileCurInt,
      importo_imponibile_percentage   as ImportoImponibilePercentage,
      provv_type                      as ProvvType,
      provv_symbol                    as ProvvSymbol,
//     @Semantics.imageUrl: true
//      _i_tipoprov.IconUri             as ProvvSymbol,
//      @ObjectModel.text.association: '_i_tipoprov'
      provv_status                    as ProvvStatus,
      document_maturanda              as DocumentMaturanda,
      document_maturata               as DocumentMaturata,
      document_fdr                    as DocumentFdr,
      document_fattura_agente         as DocumentFatturaAgente,
      document                        as Document,
      @Semantics.user.createdBy: true
      local_created_by                as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at                as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by           as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at           as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                 as LastChangedAt,
      _i_tipoprov
}
