1. Example Syntax to Add a Excel Record to the Control Table

```sql
INSERT INTO [dbo].[ControlTable]
VALUES (
--SourceObjectSettings
'{ "fileName": "%.xlsx", "folderPath": "%/%", "container": "landing" }'
--SourceConnectionSettingsName
,''
--CopySourceSettings
,'[{ "SheetName": "Sheet1", "HeaderRow": "1"}, { "SheetName": "Sheet2", "HeaderRow": "1"}]'
--SinkObjectSettings
,'{ "fileName": null, "folderPath": null, "container": "landing" }'
--SinkConnectionSettingsName
,''
--CopySinkSettings
,''
--CopyActivitySettings
,''
--TopLevelPipelineName
,'PL_2_Process_Landed_Files_Step2'
--TriggerName
,'TR_blobCreatedEvent'
--DataLoadingBehaviorSettings
,'{ "dataLoadingBehavior": "Extract_Excel_Sheets" }'
--TaskId
,0
--CopyEnabled
,1
--DataContract
,'{}'
)
```

2. Example Syntax to Add a CSV Record to the Control Table
    - Allowed values for compression for *None*, *bzip2*, *gzip*, *deflate*
```sql
INSERT INTO [dbo].[ControlTable]
VALUES (
--SourceObjectSettings
'{ "fileName": "%.csv", "folderPath": "%/%", "container": "landing" }'
--SourceConnectionSettingsName
,''
--CopySourceSettings
--Allowed values for compression for "None", "bzip2", "gzip", "deflate"
,'{ "fileType": "delimitedText", "delimiter": ",", "compression": "None"}'
--SinkObjectSettings
,'{ "fileName": null, "folderPath": "Department/Datasource/Dataset/", "container": "raw" }'
--SinkConnectionSettingsName
,''
--CopySinkSettings
,''
--CopyActivitySettings
,''
--TopLevelPipelineName
,'PL_2_Process_Landed_Files_Step2'
--TriggerName
,'TR_blobCreatedEvent'
--DataLoadingBehaviorSettings
,'{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "full" }'
--TaskId
,0
--CopyEnabled
,1
--DataContract
,'{}'
)
```

3. Example Syntax to Add a Parquet Record to the Control Table
    - Leave compression as blank

```sql
INSERT INTO [dbo].[ControlTable]
VALUES (
--SourceObjectSettings
'{ "fileName": "%.parquet", "folderPath": "%/%", "container": "landing" }'
--SourceConnectionSettingsName
,''
--CopySourceSettings
--Leave compression as blank
,'{ "fileType": "parquet", "compression": ""}'
--SinkObjectSettings
,'{ "fileName": null, "folderPath": "Department/Datasource/Dataset/", "container": "raw" }'
--SinkConnectionSettingsName
,''
--CopySinkSettings
,''
--CopyActivitySettings
,''
--TopLevelPipelineName
,'PL_2_Process_Landed_Files_Step2'
--TriggerName
,'TR_blobCreatedEvent'
--DataLoadingBehaviorSettings
,'{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "delta" }'
--TaskId
,0
--CopyEnabled
,1
--DataContract
,'{}'
)
```

4. Example Syntax to Add a JSON Record to the Control Table
    - Allowed values for compression for *None*, *bzip2*, *gzip*, *deflate*
    - Set multiline to true if a single json record spans multiple lines in the document

```sql
INSERT INTO [dbo].[ControlTable]
VALUES (
--SourceObjectSettings
'{ "fileName": "%.json", "folderPath": "%/%", "container": "landing" }'
--SourceConnectionSettingsName
,''
--CopySourceSettings
--Allowed values for compression for "None", "bzip2", "gzip", "deflate"
--Set multiline to true if a single json record spans multiple lines in the document
,'{ "fileType": "json", "multiline": false, "compression": "None"}'
--SinkObjectSettings
,'{ "fileName": null, "folderPath": "Department/Datasource/Dataset/", "container": "raw" }'
--SinkConnectionSettingsName
,''
--CopySinkSettings
,''
--CopyActivitySettings
,''
--TopLevelPipelineName
,'PL_2_Process_Landed_Files_Step2'
--TriggerName
,'TR_blobCreatedEvent'
--DataLoadingBehaviorSettings
,'{ "dataLoadingBehavior": "Copy_to_Raw", "loadType": "delta" }'
--TaskId
,0
--CopyEnabled
,1
--DataContract
,'{}'
)
```

5. Example Syntax to Add a PDF/Image Record to the Control Table for later form recognizer extraction
    - [Form Recognizer Pre-Built Models](https://learn.microsoft.com/en-us/azure/applied-ai-services/form-recognizer/concept-model-overview?view=form-recog-3.0.0#model-data-extraction)

```sql
INSERT INTO [dbo].[ControlTable]
VALUES (
--SourceObjectSettings
'{ "fileName": "%.PDF/JPEG/JPG/PNG/BMP/TIFF", "folderPath": "%/%", "container": "landing" }'
--SourceConnectionSettingsName
,''
--CopySourceSettings
--model examples include: 'prebuilt-invoice', 'prebuilt-receipt', 'prebuilt-tax.us.w2', 'prebuilt-idDocument', 'prebuilt-businessCard'
,'{ "model": "prebuilt-invoice" }'
--SinkObjectSettings
,'{ "fileName": null, "folderPath": null, "container": "landing" }'
--SinkConnectionSettingsName
,''
--CopySinkSettings
,''
--CopyActivitySettings
,''
--TopLevelPipelineName
,'PL_2_Process_Landed_Files_Step2'
--TriggerName
,'TR_blobCreatedEvent'
--DataLoadingBehaviorSettings
,'{ "dataLoadingBehavior": "Form_Recognizer_Extraction" }'
--TaskId
,0
--CopyEnabled
,1
--DataContract
,'{}'
)
```
