    class zfi_provv_sync_documents_2 definition
  public
  final
  create public .

      public section.

        interfaces if_apj_rt_run.
        interfaces if_oo_adt_classrun .

        types tt_create type table for create zc_provvigioni.

        data s_bukrs type range of bukrs.
        data s_datum type range of datum.
        data s_ghjar type range of fis_gjahr_no_conv.
        data s_doc   type range of i_journalentry-accountingdocument.

        data o_log   type ref to if_bali_log.

      protected section.

        methods set_log.
        methods save_log.
        methods set_error_message.
        methods set_message importing i_doc type i_journalentry-accountingdocument.



      private section.
ENDCLASS.



CLASS ZFI_PROVV_SYNC_DOCUMENTS_2 IMPLEMENTATION.


      method if_apj_rt_run~execute.

        data lv_amountin    type wrbtr.
        data lv_amountlocal type wrbtr.

        data lt_buzei type range of buzei.


        me->set_log( ).

        data(lv_date) = xco_cp=>sy->date( )->subtract( iv_day = 4 )->as( xco_cp_time=>format->iso_8601_basic )->value.

        select _header~accountingdocument,
               _header~fiscalyear      ,
               _header~companycode     ,
               _item~debitcreditcode,
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
       from i_journalentry   as _header
          inner join i_operationalacctgdocitem as _item on _header~accountingdocument   eq _item~accountingdocument
                                                       and _header~fiscalyear           eq _item~fiscalyear
                                                       and _header~companycode          eq _item~companycode
          inner join zfi_tp_doc            as _tp_doc   on _header~companycode          eq _tp_doc~bukrs
                                                       and _item~accountingdocumenttype eq _tp_doc~blart
          inner join zfi_conti_prov as _tp_conti_prov   on _header~companycode          eq _tp_conti_prov~bukrs
                                                       and _item~glaccount              eq _tp_conti_prov~hkont
          left join zc_provvigioni  as _provv           on _provv~accountingdocument    eq _header~accountingdocument
                                                       and _provv~fiscalyear            eq _header~fiscalyear
                                                       and _provv~companycode           eq _header~companycode
       where _header~postingdate        in @s_datum
         and _header~accountingdocument in @s_doc
         and _header~fiscalyear         in @s_ghjar
         and _header~companycode        in @s_bukrs
         and _item~financialaccounttype = 'S'    " recupero solo le posizioni co.ge.
         and _item~taxtype is initial            " escludo le posizioni iva
         and _provv~id     is null
       into table @data(lt_items).

        if sy-subrc ne 0.
          me->set_error_message( ).
          me->save_log(  ).
          return.
        endif.

        select single icon_uri from zfi_tp_provv
            where icon_id eq 'A'
        into @data(lv_icon).

        loop at lt_items into data(ls_item_grp) group by ( accountingdocument = ls_item_grp-accountingdocument
                                                           fiscalyear         = ls_item_grp-fiscalyear
                                                           companycode        = ls_item_grp-companycode  ).

          me->set_message( ls_item_grp-accountingdocument ).

          clear: lv_amountin, lv_amountlocal, lt_buzei.

          loop at group ls_item_grp assigning field-symbol(<line>).
            append value #( sign = 'I' option = 'EQ' low = <line>-accountingdocumentitem ) to  lt_buzei.
          endloop.

          select  _entryitem~accountingdocumentitem ,_entryitem~yy1_fornitore_cob2_cob from i_journalentryitem as _entryitem
            where _entryitem~accountingdocument     eq @ls_item_grp-accountingdocument
              and _entryitem~fiscalyear             eq @ls_item_grp-fiscalyear
              and _entryitem~companycode            eq @ls_item_grp-companycode
              and _entryitem~Ledger                 eq '0L'
              and _entryitem~accountingdocumentitem in @lt_buzei
              and _entryitem~yy1_fornitore_cob2_cob is not initial
          into table @data(lt_agents).

          " Customer
          select single customer
            from i_operationalacctgdocitem
            where accountingdocument = @ls_item_grp-accountingdocument
              and fiscalyear         = @ls_item_grp-fiscalyear
              and companycode        = @ls_item_grp-companycode
              and customer is not initial
            into @data(lv_customer).

          loop at lt_agents assigning field-symbol(<agent>) group by <agent>-yy1_fornitore_cob2_cob.

            clear: lv_amountin, lv_amountlocal.

            loop at group <agent> assigning field-symbol(<buzei>).

              if not line_exists( lt_items[ accountingdocument     = ls_item_grp-accountingdocument
                                            fiscalyear             = ls_item_grp-fiscalyear
                                            companycode            = ls_item_grp-companycode
                                            accountingdocumentitem = <buzei>-accountingdocumentitem ] ).
                continue.
              endif.

              data(ls_item) = lt_items[ accountingdocument     = ls_item_grp-accountingdocument
                                        fiscalyear             = ls_item_grp-fiscalyear
                                        companycode            = ls_item_grp-companycode
                                        accountingdocumentitem = <buzei>-accountingdocumentitem ].

              lv_amountin    = lv_amountin    + ls_item-amountintransactioncurrency.
              lv_amountlocal = lv_amountlocal + ls_item-amountincompanycodecurrency.

            endloop.


            try.
                data(lv_uuid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
              catch cx_uuid_error.
                return.
            endtry.

            data(lt_create) = value tt_create( ( %cid = lv_uuid
                                                 companycode = ls_item-companycode
                                                 agentcode = <agent>-yy1_fornitore_cob2_cob
                                                 customercode = lv_customer
                                                 postingdate = ls_item-postingdate
                                                 accountingdocument = ls_item-accountingdocument
                                                 fiscalyear = ls_item-fiscalyear
                                                 importoprovvvalint = lv_amountlocal
                                                 importoprovvvalintcurrency = ls_item-companycodecurrency
                                                 importoprovvvaldoc = lv_amountin
                                                 importoprovvvaldoccurrency = ls_item-transactioncurrency
*                                                ImportoImponibile = lv_amountin
*                                                ImportoImponibileCurrency = 'EUR'
                                                 importoimponibilepercentage = 0
                                                 provvtype = 'A'
                                                 provvsymbol = lv_icon
                                                 provvstatus = 1
                                                 documentmaturanda = |{ ls_item-accountingdocument }-{ ls_item-fiscalyear }|
                                               ) ).
*
            modify entities of zc_provvigioni
            entity zfiprovvigioni
            create fields ( companycode
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
                        document )
  with lt_create
  mapped data(mapped_002)
  reported data(reported_002)
  failed data(failed_002).

            commit entities.
          endloop.
        endloop.

        me->save_log(  ).


      endmethod.


      method set_log.

        try.
            o_log = cl_bali_log=>create_with_header( header = cl_bali_header_setter=>create( object    = 'ZFI_PROVVIGIONE_LOG'
                                                                                             subobject = 'ZFI_SYNC_LOG' ) ).

          catch  cx_bali_runtime into data(l_runtime_exception).
            return.
        endtry.

      endmethod.


      method save_log.

        try.
            cl_bali_log_db=>get_instance( )->save_log_2nd_db_connection( log = o_log
                                                                         assign_to_current_appl_job = abap_true ).
          catch  cx_bali_runtime into data(l_runtime_exception).
            return.
        endtry.

      endmethod.


      method set_message.

        try.
            o_log->add_item( item = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_information
                                                                      text = |Documento "{ i_doc }" rilevante per cruscotto provvigioni| ) ).

          catch  cx_bali_runtime into data(l_runtime_exception).
            return.
        endtry.

      endmethod.


      method set_error_message.

        try.
            o_log->add_item( item = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_exit
                                                                      text = |Nessun documento trovato| ) ).

          catch  cx_bali_runtime into data(l_runtime_exception).
            return.
        endtry.

      endmethod.


      method if_oo_adt_classrun~main.
        try.
            append value #( sign = 'I' option = 'EQ' low = 'WA1001092' ) to s_doc.
            me->if_apj_rt_run~execute( ).
          catch cx_apj_rt_content.
            return.
        endtry.
      endmethod.
ENDCLASS.
