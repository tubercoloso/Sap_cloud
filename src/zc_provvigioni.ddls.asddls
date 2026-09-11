@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View Travel Analytical Table'
@OData.applySupportedForAggregation: #FULL

define root view entity ZC_PROVVIGIONI
  provider contract transactional_query
  as projection on ZI_PROVVIGIONI
{
  key Id,
      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      CompanyCode,
      CompanyCodeName,
      @ObjectModel.text.element: [ 'SupplierName' ]
      AgentCode,
      SupplierName,
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerCode,
      CustomerName,
      PostingDate,
      AccountingDocument,

      @Semantics.calendar.year: true
      FiscalYear,

      @Aggregation.default: #SUM
      @Semantics.amount.currencyCode : 'ImportoProvvValIntCurrency'
      ImportoProvvValInt,
      @Semantics.currencyCode: true
      ImportoProvvValIntCurrency,

      @Aggregation.default: #SUM
      @Semantics.amount.currencyCode : 'ImportoProvvValDocCurrency'
      ImportoProvvValDoc,
      @Semantics.currencyCode: true
      ImportoProvvValDocCurrency,

      @Aggregation.default: #SUM
      @Semantics.amount.currencyCode : 'ImportoImponibileCurrency'
      ImportoImponibile,
      @Semantics.currencyCode: true
      ImportoImponibileCurrency,
      @Aggregation.default: #SUM
      @Semantics.amount.currencyCode : 'ImportoImponibileCurInt'
      ImportoImponibileInt,
      ImportoImponibileCurInt,

      ImportoImponibilePercentage,
      ProvvType,
      @Semantics.imageUrl: true
      ProvvSymbol,
      ProvvStatus,
      DocumentMaturanda,
      DocumentMaturata,
      DocumentFdr,
      DocumentFatturaAgente,
      Document,
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt
}
