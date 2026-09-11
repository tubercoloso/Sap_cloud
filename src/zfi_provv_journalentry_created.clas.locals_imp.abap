class lcl_abap_behv_event_handler definition inheriting from cl_abap_behavior_event_handler.
*
  private section.
*
    methods consume_created for entity event created_instances for journalentry~created.
*
endclass.

class lcl_abap_behv_event_handler implementation.

  method consume_created.
*
    types tt_create type table for create zc_provvigioni.

    data lt_buzei type range of buzei.

    select single icon_uri from zfi_tp_provv
        where icon_id eq 'A'
     into @data(lv_icon).
*
    loop at created_instances into data(created_instance).
*
      select _item~debitcreditcode,
             _item~amountintransactioncurrency,
             _item~taxcode,
             _item~amountincompanycodecurrency,
             _header~documentdate,
             _header~postingdate,
             _header~isreversal,
             _header~isreversed,
             _header~reversedocument,
             _header~reversedocumentfiscalyear,
             _item~absoluteamountincocodecrcy,
             _item~companycodecurrency,
             _item~absoluteamountintransaccrcy,
             _item~transactioncurrency,
             _item~accountingdocumentitem

        " header
        from i_journalentry   as _header
*        INNER JOIN I_JournalEntryItem AS _entryitem
*          ON  _header~AccountingDocument = _entryitem~AccountingDocument
*          AND _header~FiscalYear         = _entryitem~FiscalYear
*          AND _header~CompanyCode        = _entryitem~CompanyCode
        " item
        inner join i_operationalacctgdocitem as _item
          on  _header~accountingdocument = _item~accountingdocument
          and _header~fiscalyear         = _item~fiscalyear
          and _header~companycode        = _item~companycode
        " Z
        " Origine documento: documenti provenienti da Stealth/AX à Tipi documento specifici fattura emessa (ML)
        inner join zfi_tp_doc as _tp_doc
          on  _header~companycode           = _tp_doc~bukrs
          and _item~accountingdocumenttype  = _tp_doc~blart
        " Z
        " Contabilità Generale: presenza di uno o più conti Co.Ge. parametrici “ZFI_CONTI_PROVV”, definiti a sistema.
        inner join zfi_conti_prov as _tp_conti_prov
          on  _header~companycode           = _tp_conti_prov~bukrs
          and _item~glaccount               = _tp_conti_prov~hkont
*
        where _header~accountingdocument = @created_instance-accountingdocument
          and _header~fiscalyear         = @created_instance-fiscalyear
          and _header~companycode        = @created_instance-companycode
          and _item~financialaccounttype = 'S'    " recupero solo le posizioni co.ge.
          and _item~taxtype is initial            " escludo le posizioni iva
        into table @data(lt_items).
*
      data lv_amountin type wrbtr.
      data lv_amountlocal type wrbtr.

      lt_buzei = value #( for wa in lt_items ( sign = 'I' option = 'EQ' low = wa-accountingdocumentitem ) ).

      select  _entryitem~accountingdocumentitem ,_entryitem~yy1_fornitore_cob2_cob from i_journalentryitem as _entryitem
        where _entryitem~accountingdocument     eq @created_instance-accountingdocument
          and _entryitem~fiscalyear             eq @created_instance-fiscalyear
          and _entryitem~companycode            eq @created_instance-companycode
          and _entryitem~Ledger                 eq '0L'
          and _entryitem~accountingdocumentitem in @lt_buzei
          and _entryitem~yy1_fornitore_cob2_cob is not initial
      into table @data(lt_agents).

      " Customer
      select single customer
        from i_operationalacctgdocitem
        where accountingdocument = @created_instance-accountingdocument
          and fiscalyear         = @created_instance-fiscalyear
          and companycode        = @created_instance-companycode
          and customer is not initial
        into @data(lv_customer).


      loop at lt_agents assigning field-symbol(<agent>) group by <agent>-yy1_fornitore_cob2_cob.

        clear: lv_amountin, lv_amountlocal .

        loop at group <agent> assigning field-symbol(<buzei>).

          if not line_exists( lt_items[ accountingdocumentitem = <buzei>-accountingdocumentitem ] ).
            continue.
          endif.

          data(ls_item) = lt_items[ accountingdocumentitem = <buzei>-accountingdocumentitem ].

          lv_amountin    = lv_amountin    + ls_item-amountintransactioncurrency.
          lv_amountlocal = lv_amountlocal + ls_item-amountincompanycodecurrency.

        endloop.

        try.
            data(lv_uuid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
          catch cx_uuid_error.
            return.
        endtry.
*
        data(lt_create) = value tt_create( (
          %cid = lv_uuid
          companycode = created_instance-companycode
          agentcode = <agent>-yy1_fornitore_cob2_cob
          customercode = lv_customer
          postingdate = ls_item-postingdate
          accountingdocument = created_instance-accountingdocument
          fiscalyear = created_instance-fiscalyear
          importoprovvvalint = lv_amountlocal
          importoprovvvalintcurrency = ls_item-companycodecurrency
          importoprovvvaldoc = lv_amountin
          importoprovvvaldoccurrency = ls_item-transactioncurrency
*        ImportoImponibile = lv_amountin
*        ImportoImponibileCurrency = 'EUR'
          importoimponibilepercentage = 0
          provvtype = 'A'
          provvsymbol = lv_icon
          provvstatus = 1
          documentmaturanda = |{ created_instance-accountingdocument }-{ created_instance-fiscalyear }|
        ) ).
*
        modify entities of zc_provvigioni
            entity zfiprovvigioni
                create fields (
                  companycode
                  agentcode
                  customercode
                  postingdate
                  accountingdocument
                  fiscalyear
                  importoprovvvalint
                  importoprovvvalintcurrency
                  importoprovvvaldoc
                  importoprovvvaldoccurrency
                  importoimponibile
                  importoimponibilecurrency
                  importoimponibilepercentage
                  provvtype
                  provvsymbol
                  provvstatus
                  documentmaturanda
                  documentmaturata
                  documentfdr
                  documentfatturaagente
                  document
                )
        with lt_create
        mapped data(mapped_002)
        reported data(reported_002)
        failed data(failed_002).
*
      endloop.
    endloop.
*
  endmethod.
*
endclass.
