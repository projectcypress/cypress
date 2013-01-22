<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<sch:schema xmlns:voc="http://www.lantanagroup.com/voc" xmlns:svs="urn:ihe:iti:svs:2008" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:cda="urn:hl7-org:v3" xmlns="urn:hl7-org:v3" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:ns prefix="voc" uri="http://www.lantanagroup.com/voc" />
  <sch:ns prefix="svs" uri="urn:ihe:iti:svs:2008" />
  <sch:ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance" />
  <sch:ns prefix="cda" uri="urn:hl7-org:v3" />
  <sch:ns prefix="sdtc" uri="urn:hl7-org:sdtc" />      
  <sch:phase id="errors">
    <sch:active pattern="p-sdtc-errors-code" />
    <sch:active pattern="p-sdtc-errors-value" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.104-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.61-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.41-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.65-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.83-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.84-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.9-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.85-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.44-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.1-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.63-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.14-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.66-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.2-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.64-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.88-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.89-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.62-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.4-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.82-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.2-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.87-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.91-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.93-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.38-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.16-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.40-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.15-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.39-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.3-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.49-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.23-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.21-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.40-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.24-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.22-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.37-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.4-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.11-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.13-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.14-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.16-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.41-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.90-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.5-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.6-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.8-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.6-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.94-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.95-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.96-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.76-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.78-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.79-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.43-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.9-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.10-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.7-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.42-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.48-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.67-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.69-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.69-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.79-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.54-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.51-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.55-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.42-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.47-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.13-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.59-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.60-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.58-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.57-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.26-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.25-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.17.2.4-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.2.1-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.2.2-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.2.3-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.98-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.97-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.27-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.67-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.28-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.77-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.1.1-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.1.1-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.18-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.1.2-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.81-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.100-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.19-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.17-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.29-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.12-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.32-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.30-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.34-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.39-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.31-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.75-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.33-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.20-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.99-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.18-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.45-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.36-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.35-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.7-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.46-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.43-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.44-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.45-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.12-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.102-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.101-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.103-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.105-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.25-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.20-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.23-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.17-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.54-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.19-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.24-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.8-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.32-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.37-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.80-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.31-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.5-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.28-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.86-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.85-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.50-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.72-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.17.2.1-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.17.3.8-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.46-errors" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.47-errors" />
  </sch:phase>
  <sch:phase id="warnings">
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.104-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.61-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.41-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.65-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.83-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.84-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.9-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.85-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.44-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.1-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.63-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.14-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.66-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.2-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.64-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.88-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.89-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.62-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.4-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.82-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.2-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.87-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.91-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.93-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.38-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.16-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.40-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.15-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.39-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.3-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.49-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.23-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.21-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.40-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.24-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.22-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.37-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.4-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.11-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.13-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.14-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.16-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.41-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.90-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.5-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.6-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.8-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.6-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.94-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.95-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.96-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.76-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.78-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.79-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.43-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.9-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.10-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.7-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.42-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.48-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.67-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.69-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.69-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.79-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.54-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.51-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.55-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.42-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.47-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.13-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.59-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.60-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.58-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.57-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.26-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.25-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.17.2.4-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.2.1-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.2.2-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.2.3-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.98-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.97-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.27-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.67-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.28-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.77-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.1.1-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.1.1-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.18-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.1.2-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.81-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.100-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.19-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.17-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.29-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.12-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.32-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.30-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.34-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.39-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.31-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.75-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.33-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.20-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.99-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.18-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.45-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.36-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.35-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.7-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.46-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.43-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.44-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.45-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.12-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.102-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.101-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.103-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.105-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.25-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.20-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.23-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.17-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.54-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.19-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.24-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.8-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.32-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.37-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.80-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.31-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.5-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.28-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.86-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.85-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.50-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.72-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.17.2.1-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.17.3.8-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.46-warnings" />
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.4.47-warnings" />
  </sch:phase>
  <sch:pattern id="p-sdtc-errors-code">
    <sch:rule id="r-sdtc-errors-abstract-code" abstract="true">
      <sch:assert id="a-sdtc-code-codeSystem-exists" test="(current()[@codeSystem or @nullFlavor])">@codeSystem or @nullFlavor is required for code element.</sch:assert>
    </sch:rule>
    <sch:rule id="r-sdtc-errors-code" context="cda:code">
      <sch:extends rule="r-sdtc-errors-abstract-code" />
    </sch:rule>    
  </sch:pattern>
  <sch:pattern id="p-sdtc-errors-value">
    <sch:rule id="r-sdtc-errors-abstract-value" abstract="true">
      <sch:assert id="a-sdtc-value-CD-codeSystem-exists" test="not(current()[@xsi:type='CD']) or current()[@codeSystem or @nullFlavor]">@codeSystem is required for value element if xsi:type=CD.</sch:assert>
      <sch:assert id="a-sdtc-value-CE-codeSystem-exists" test="not(current()[@xsi:type='CE']) or current()[@codeSystem or @nullFlavor]">@codeSystem is required for value element if xsi:type=CE.</sch:assert>
    </sch:rule>
    <sch:rule id="r-sdtc-errors-value" context="cda:value">
      <sch:extends rule="r-sdtc-errors-abstract-value" />
    </sch:rule>    
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.104-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.104-errors-abstract" abstract="true">
      <sch:assert id="a-16379" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:16379).</sch:assert>
      <sch:assert id="a-16380" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:16380).</sch:assert>
      <sch:assert id="a-16384" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:16384).</sch:assert>
      <sch:assert id="a-16385" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:16385).</sch:assert>
      <sch:assert id="a-16386" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:16386).</sch:assert>
      <sch:assert id="a-16387" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:16387).</sch:assert>
      <sch:assert id="a-16388" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:16388).</sch:assert>
      <sch:assert id="a-16389" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:16389).</sch:assert>
      <sch:assert id="a-16390" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:16390).</sch:assert>
      <sch:assert id="a-16393" test="count(cda:entryRelationship[@typeCode='CAUS'])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:16392) such that it SHALL contain exactly one [1..1] @inversionInd="true" (CONF:16394). SHALL contain exactly one [1..1] @typeCode="CAUS" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:16393).</sch:assert>
      <sch:assert id="a-16394" test="count(cda:entryRelationship[@inversionInd='true'])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:16392) such that it SHALL contain exactly one [1..1] @typeCode="CAUS" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:16393). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:16394).</sch:assert>
      <sch:assert id="a-16406" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:16406).</sch:assert>
      <sch:assert id="a-16407" test="cda:value[@code and @code=document('2.16.840.1.113883.3.88.12.3221.6.2.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.3.88.12.3221.6.2']/svs:ConceptList/svs:Concept/@code]">This value SHALL contain exactly one [1..1] @code, which SHALL be selected from ValueSet Allergy/Adverse Event Type 2.16.840.1.113883.3.88.12.3221.6.2 STATIC (CONF:16407).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.104-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.104']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-errors-abstract" />
      <sch:assert id="a-16382" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.104'])=1">SHALL contain exactly one [1..1] templateId (CONF:16381) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.104" (CONF:16382).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.61-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.61-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-errors-abstract" />
      <sch:assert id="a-11373" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11373).</sch:assert>
      <sch:assert id="a-11374" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11374).</sch:assert>
      <sch:assert id="a-11375" test="count(cda:templateId)=1">SHALL contain exactly one [1..1] templateId (CONF:11375).</sch:assert>
      <sch:assert id="a-11377" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:11377).</sch:assert>
      <sch:assert id="a-11378" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11378).</sch:assert>
      <sch:assert id="a-11379" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:11379).</sch:assert>
      <sch:assert id="a-11381" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11381).</sch:assert>
      <sch:assert id="a-11382" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11382).</sch:assert>
      <sch:assert id="a-11383" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:11383).</sch:assert>
      <sch:assert id="a-11388" test="count(cda:entryRelationship[@typeCode='CAUS'][@inversionInd='true'][count(cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:11385) such that it SHALL contain exactly one [1..1] @typeCode="CAUS" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:11386). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:11387). SHALL contain exactly one [1..1] Procedure Performed (templateId:2.16.840.1.113883.10.20.24.3.64) (CONF:11388).</sch:assert>
      <sch:assert id="a-16419" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:16419).</sch:assert>
      <sch:assert id="a-16420" test="cda:value[@code='281647001' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="281647001" Adverse reaction (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16420).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.61-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.61']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.61-errors-abstract" />
      <sch:assert id="a-11376" test="cda:templateId[@root='2.16.840.1.113883.10.20.24.3.29']">This templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.29" (CONF:11376).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.41-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.41-errors-abstract" abstract="true">
      <sch:assert id="a-8568" test="@classCode='PROC'">SHALL contain exactly one [1..1] @classCode="PROC" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8568).</sch:assert>
      <sch:assert id="a-8569" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.23.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.23']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet Plan of Care moodCode (Act/Encounter/Procedure) 2.16.840.1.113883.11.20.9.23 STATIC 2011-09-30 (CONF:8569).</sch:assert>
      <sch:assert id="a-8571" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8571).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.41-errors" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.41']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.41-errors-abstract" />
      <sch:assert id="a-10513" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.41'])=1">SHALL contain exactly one [1..1] templateId (CONF:8570) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.41" (CONF:10513).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.65-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.65-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.41-errors-abstract" />
      <sch:assert id="a-11103" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11103).</sch:assert>
      <sch:assert id="a-11107" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11107).</sch:assert>
      <sch:assert id="a-11581" test="count(cda:author)=1">SHALL contain exactly one [1..1] author (CONF:11581).</sch:assert>
      <sch:assert id="a-11582" test="cda:author[count(cda:time)=1]">This author SHALL contain exactly one [1..1] time (CONF:11582).</sch:assert>
      <sch:assert id="a-13239" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:13239).</sch:assert>
      <sch:assert id="a-13240" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13240).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.65-errors" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.65']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.65-errors-abstract" />
      <sch:assert id="a-11105" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.65'])=1">SHALL contain exactly one [1..1] templateId (CONF:11104) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.65" (CONF:11105).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.83-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.83-errors-abstract" abstract="true">
      <sch:assert id="a-11118" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS", which SHALL be selected from CodeSystem HL7ActClass (2.16.840.1.113883.5.6) STATIC (CONF:11118).</sch:assert>
      <sch:assert id="a-11119" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11119).</sch:assert>
      <sch:assert id="a-11120" test="count(cda:templateId)=1">SHALL contain exactly one [1..1] templateId (CONF:11120).</sch:assert>
      <sch:assert id="a-11123" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11123).</sch:assert>
      <sch:assert id="a-11124" test="cda:code[@code='PAT' and @codeSystem='2.16.840.1.113883.5.8']">This code SHALL contain exactly one [1..1] @code="PAT" Patient Request (CodeSystem: HL7 Act Accommodation Reason 2.16.840.1.113883.5.8 STATIC) (CONF:11124).</sch:assert>
      <sch:assert id="a-11125" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:11125).</sch:assert>
      <sch:assert id="a-11355" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:11355).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.83-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.83']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.83-errors-abstract" />
      <sch:assert id="a-11121" test="cda:templateId[@root='2.16.840.1.113883.10.20.24.3.83']">This templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.83" (CONF:11121).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.84-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.84-errors-abstract" abstract="true">
      <sch:assert id="a-11126" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11126).</sch:assert>
      <sch:assert id="a-11127" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11127).</sch:assert>
      <sch:assert id="a-11128" test="count(cda:templateId)=1">SHALL contain exactly one [1..1] templateId (CONF:11128).</sch:assert>
      <sch:assert id="a-11131" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11131).</sch:assert>
      <sch:assert id="a-11132" test="cda:code[@code='103323008' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="103323008" provider preference (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:11132).</sch:assert>
      <sch:assert id="a-11323" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:11323).</sch:assert>
      <sch:assert id="a-11356" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:11356).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.84-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.84']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.84-errors-abstract" />
      <sch:assert id="a-11129" test="cda:templateId[@root='2.16.840.1.113883.10.20.24.3.84']">This templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.84" (CONF:11129).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.9-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.9-errors-abstract" abstract="true">
      <sch:assert id="a-7325" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7325).</sch:assert>
      <sch:assert id="a-7326" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7326).</sch:assert>
      <sch:assert id="a-7328" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:7328).</sch:assert>
      <sch:assert id="a-7329" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:7329).</sch:assert>
      <sch:assert id="a-7335" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet Problem 2.16.840.1.113883.3.88.12.3221.7.4 DYNAMIC (CONF:7335).</sch:assert>
      <sch:assert id="a-16851" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:16851).</sch:assert>
      <sch:assert id="a-19114" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19114).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.9-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.9']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.9-errors-abstract" />
      <sch:assert id="a-10523" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.9'])=1">SHALL contain exactly one [1..1] templateId (CONF:7323) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.9" (CONF:10523).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.85-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.85-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.9-errors-abstract" />
      <sch:assert id="a-11370" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11370).</sch:assert>
      <sch:assert id="a-11661" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11661).</sch:assert>
      <sch:assert id="a-11662" test="cda:code[@code='263851003' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="263851003" reaction (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:11662).</sch:assert>
      <sch:assert id="a-11663" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:11663).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.85-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.85-errors-abstract" />
      <sch:assert id="a-11333" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.85'])=1">SHALL contain exactly one [1..1] templateId (CONF:11332) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.85" (CONF:11333).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.44-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" abstract="true">
      <sch:assert id="a-8581" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8581).</sch:assert>
      <sch:assert id="a-8582" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.25.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.25']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet Plan of Care moodCode (Observation) 2.16.840.1.113883.11.20.9.25 STATIC 2011-09-30 (CONF:8582).</sch:assert>
      <sch:assert id="a-8584" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8584).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.44-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.44']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" />
      <sch:assert id="a-10512" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.44'])=1">SHALL contain exactly one [1..1] templateId (CONF:8583) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.44" (CONF:10512).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.1-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.1-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" />
      <sch:assert id="a-11245" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11245).</sch:assert>
      <sch:assert id="a-11246" test="@moodCode='GOL'">SHALL contain exactly one [1..1] @moodCode="GOL" goal (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11246).</sch:assert>
      <sch:assert id="a-11251" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11251).</sch:assert>
      <sch:assert id="a-11252" test="cda:code[@code]">This code SHALL contain exactly one [1..1] @code (CONF:11252).</sch:assert>
      <sch:assert id="a-11253" test="cda:code[@codeSystem]">This code SHALL contain exactly one [1..1] @codeSystem (CONF:11253).</sch:assert>
      <sch:assert id="a-11254" test="count(cda:statusCode[@code='active'])=1">SHALL contain exactly one [1..1] statusCode="active" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11254).</sch:assert>
      <sch:assert id="a-11255" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11255).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.1-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.1-errors-abstract" />
      <sch:assert id="a-11248" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.1'])=1">SHALL contain exactly one [1..1] templateId (CONF:11247) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.1" (CONF:11248).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.63-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.63-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.41-errors-abstract" />
      <sch:assert id="a-11097" test="@moodCode='RQO'">SHALL contain exactly one [1..1] @moodCode="RQO" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11097).</sch:assert>
      <sch:assert id="a-11101" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11101).</sch:assert>
      <sch:assert id="a-11595" test="count(cda:author)=1">SHALL contain exactly one [1..1] author (CONF:11595).</sch:assert>
      <sch:assert id="a-11596" test="cda:author[count(cda:time)=1]">This author SHALL contain exactly one [1..1] time (CONF:11596).</sch:assert>
      <sch:assert id="a-14576" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:14576).</sch:assert>
      <sch:assert id="a-14577" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CONF:14577).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.63-errors" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.63']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.63-errors-abstract" />
      <sch:assert id="a-11099" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.63'])=1">SHALL contain exactly one [1..1] templateId (CONF:11098) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.63" (CONF:11099).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.14-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.14-errors-abstract" abstract="true">
      <sch:assert id="a-7652" test="@classCode='PROC'">SHALL contain exactly one [1..1] @classCode="PROC" Procedure (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7652).</sch:assert>
      <sch:assert id="a-7653" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.18.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.18']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet MoodCodeEvnInt 2.16.840.1.113883.11.20.9.18 STATIC 2011-04-03 (CONF:7653).</sch:assert>
      <sch:assert id="a-7655" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:7655).</sch:assert>
      <sch:assert id="a-7656" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:7656).</sch:assert>
      <sch:assert id="a-7661" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode, which SHALL be selected from ValueSet ProcedureAct statusCode 2.16.840.1.113883.11.20.9.22 DYNAMIC (CONF:7661).</sch:assert>
      <sch:assert id="a-19206" test="count(cda:code/cda:originalText/cda:reference[@value])=0 or starts-with(cda:code/cda:originalText/cda:reference/@value, '#')">This reference/@value SHALL begin with a '#' and SHALL point to its corresponding narrative (using the approach defined in CDA Release 2, section 4.3.5.1) (CONF:19206).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.14-errors" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.14']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.14-errors-abstract" />
      <sch:assert id="a-10521" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.14'])=1">SHALL contain exactly one [1..1] templateId (CONF:7654) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.14" (CONF:10521).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.66-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.66-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.14-errors-abstract" />
      <sch:assert id="a-11112" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11112).</sch:assert>
      <sch:assert id="a-11113" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11113).</sch:assert>
      <sch:assert id="a-11114" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11114).</sch:assert>
      <sch:assert id="a-11117" test="count(cda:entryRelationship[@typeCode='REFR'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.87'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:11115) such that it SHALL contain exactly one [1..1] @typeCode="REFR" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:11116). SHALL contain exactly one [1..1] Result (templateId:2.16.840.1.113883.10.20.24.3.87) (CONF:11117).</sch:assert>
      <sch:assert id="a-11696" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:11696).</sch:assert>
      <sch:assert id="a-11697" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:11697).</sch:assert>
      <sch:assert id="a-14169" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:14169).</sch:assert>
      <sch:assert id="a-14170" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:14170).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.66-errors" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.66']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.66-errors-abstract" />
      <sch:assert id="a-11110" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.66'])=1">SHALL contain exactly one [1..1] templateId (CONF:11109) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.66" (CONF:11110).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.2-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.2-errors-abstract" abstract="true">
      <sch:assert id="a-11484" test="@classCode='ACT'">SHALL contain exactly one [1..1] @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11484).</sch:assert>
      <sch:assert id="a-11485" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11485).</sch:assert>
      <sch:assert id="a-11619" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:11619).</sch:assert>
      <sch:assert id="a-11620" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed", which SHALL be selected from CodeSystem ActStatus (2.16.840.1.113883.5.14) STATIC (CONF:11620).</sch:assert>
      <sch:assert id="a-11622" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11622).</sch:assert>
      <sch:assert id="a-11633" test="count(cda:participant[@typeCode='IRCP'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CONF:11631) such that it SHALL contain exactly one [1..1] @typeCode="IRCP" information recipient (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:11632). SHALL contain exactly one [1..1] participantRole (CONF:11633).</sch:assert>
      <sch:assert id="a-11651" test="cda:participant[@typeCode='IRCP']/cda:participantRole[count(cda:code[@code='158965000'][@codeSystem='2.16.840.1.113883.6.96'])=1]">This participantRole SHALL contain exactly one [1..1] code="158965000" medical practitioner (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:11651).</sch:assert>
      <sch:assert id="a-11836" test="count(cda:participant[@typeCode='AUT'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CONF:11835) such that it SHALL contain exactly one [1..1] @typeCode="AUT" author (originator) (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:12099). SHALL contain exactly one [1..1] participantRole (CONF:11836).</sch:assert>
      <sch:assert id="a-12098" test="cda:participant[@typeCode='IRCP']/cda:participantRole[@classCode='ASSIGNED']">This participantRole SHALL contain exactly one [1..1] @classCode="ASSIGNED" assigned entity (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:12098).</sch:assert>
      <sch:assert id="a-12100" test="cda:participant[@typeCode='AUT']/cda:participantRole[@classCode='PAT']">This participantRole SHALL contain exactly one [1..1] @classCode="PAT" patient (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:12100).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.2-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.2-errors-abstract" />
      <sch:assert id="a-11487" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.2'])=1">SHALL contain exactly one [1..1] templateId (CONF:11486) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.2" (CONF:11487).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.64-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.64-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.14-errors-abstract" />
      <sch:assert id="a-11261" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11261).</sch:assert>
      <sch:assert id="a-11669" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11669).</sch:assert>
      <sch:assert id="a-11670" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:11670).</sch:assert>
      <sch:assert id="a-11671" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:11671).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.64-errors" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.64-errors-abstract" />
      <sch:assert id="a-11263" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.64'])=1">SHALL contain exactly one [1..1] templateId (CONF:11262) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.64" (CONF:11263).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.88-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.88-errors-abstract" abstract="true">
      <sch:assert id="a-11357" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11357).</sch:assert>
      <sch:assert id="a-11358" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11358).</sch:assert>
      <sch:assert id="a-11359" test="count(cda:templateId)=1">SHALL contain exactly one [1..1] templateId (CONF:11359).</sch:assert>
      <sch:assert id="a-11361" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11361).</sch:assert>
      <sch:assert id="a-11362" test="cda:code[@code='410666004' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="410666004" reason (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:11362).</sch:assert>
      <sch:assert id="a-11364" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11364).</sch:assert>
      <sch:assert id="a-11365" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11365).</sch:assert>
      <sch:assert id="a-11366" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11366).</sch:assert>
      <sch:assert id="a-11367" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:11367).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.88-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.88-errors-abstract" />
      <sch:assert id="a-11360" test="cda:templateId[@root='2.16.840.1.113883.10.20.24.3.88']">This templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.88" (CONF:11360).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.89-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.89-errors-abstract" abstract="true">
      <sch:assert id="a-11401" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11401).</sch:assert>
      <sch:assert id="a-14559" test="@classCode='PROC'">SHALL contain exactly one [1..1] @classCode="PROC" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:14559).</sch:assert>
      <sch:assert id="a-14561" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:14561).</sch:assert>
      <sch:assert id="a-14562" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:14562).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.89-errors" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.89']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.89-errors-abstract" />
      <sch:assert id="a-11403" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.89'])=1">SHALL contain exactly one [1..1] templateId (CONF:11402) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.89" (CONF:11403).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.62-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.62-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-errors-abstract" />
      <sch:assert id="a-11433" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11433).</sch:assert>
      <sch:assert id="a-11434" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11434).</sch:assert>
      <sch:assert id="a-11437" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:11437).</sch:assert>
      <sch:assert id="a-11438" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11438).</sch:assert>
      <sch:assert id="a-11439" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:11439).</sch:assert>
      <sch:assert id="a-11441" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11441).</sch:assert>
      <sch:assert id="a-11442" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11442).</sch:assert>
      <sch:assert id="a-11443" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11443).</sch:assert>
      <sch:assert id="a-11444" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:11444).</sch:assert>
      <sch:assert id="a-13940" test="count(cda:entryRelationship[@typeCode='CAUS'][@inversionInd='true'][count(cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:11601) such that it SHALL contain exactly one [1..1] @typeCode="CAUS" (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:11602). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:11603). SHALL contain exactly one [1..1] Procedure Performed (templateId:2.16.840.1.113883.10.20.24.3.64) (CONF:13940).</sch:assert>
      <sch:assert id="a-14574" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:14574).</sch:assert>
      <sch:assert id="a-16421" test="cda:value[@code='102460003' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="102460003" Decreased tolerance (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16421).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.4-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.4-errors-abstract" abstract="true">
      <sch:assert id="a-11816" test="@classCode='ACT'">SHALL contain exactly one [1..1] @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11816).</sch:assert>
      <sch:assert id="a-11817" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11817).</sch:assert>
      <sch:assert id="a-11821" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:11821).</sch:assert>
      <sch:assert id="a-11822" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11822).</sch:assert>
      <sch:assert id="a-11823" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11823).</sch:assert>
      <sch:assert id="a-11829" test="count(cda:participant[@typeCode='IRCP'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CONF:11827) such that it SHALL contain exactly one [1..1] @typeCode="IRCP" information recipient (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:11828). SHALL contain exactly one [1..1] participantRole (CONF:11829).</sch:assert>
      <sch:assert id="a-11830" test="cda:participant[@typeCode='IRCP']/cda:participantRole[count(cda:code[@code='158965000'][@codeSystem='2.16.840.1.113883.6.96'])=1]">This participantRole SHALL contain exactly one [1..1] code="158965000" Medical Practitioner (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:11830).</sch:assert>
      <sch:assert id="a-11839" test="count(cda:participant[@typeCode='AUT'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CONF:11837) such that it SHALL contain exactly one [1..1] @typeCode="AUT" author (originator) (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:11838). SHALL contain exactly one [1..1] participantRole (CONF:11839).</sch:assert>
      <sch:assert id="a-12096" test="cda:participant[@typeCode='IRCP']/cda:participantRole[@classCode='ASSIGNED']">This participantRole SHALL contain exactly one [1..1] @classCode="ASSIGNED" assigned entity (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:12096).</sch:assert>
      <sch:assert id="a-12097" test="cda:participant[@typeCode='AUT']/cda:participantRole[@classCode='ASSIGNED']">This participantRole SHALL contain exactly one [1..1] @classCode="ASSIGNED" assigned entity (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:12097).</sch:assert>
      <sch:assert id="a-12103" test="cda:participant[@typeCode='AUT']/cda:participantRole[count(cda:code[@code='158965000'][@codeSystem='2.16.840.1.113883.6.96'])=1]">This participantRole SHALL contain exactly one [1..1] code="158965000" Medical Practitioner (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12103).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.4-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.4']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.4-errors-abstract" />
      <sch:assert id="a-11819" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.4'])=1">SHALL contain exactly one [1..1] templateId (CONF:11818) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.4" (CONF:11819).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.82-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.82-errors-abstract" abstract="true">
      <sch:assert id="a-13178" test="count(cda:time)=1">SHALL contain exactly one [1..1] time (CONF:13178).</sch:assert>
      <sch:assert id="a-13179" test="count(cda:participantRole)=1">SHALL contain exactly one [1..1] participantRole (CONF:13179).</sch:assert>
      <sch:assert id="a-13180" test="cda:participantRole[@classCode='LOCE']">This participantRole SHALL contain exactly one [1..1] @classCode="LOCE" located entity (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:13180).</sch:assert>
      <sch:assert id="a-13181" test="@typeCode='DST'">SHALL contain exactly one [1..1] @typeCode="DST" destination (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:13181).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.82-errors" context="cda:Participant2[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.82']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.82-errors-abstract" />
      <sch:assert id="a-13183" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.82'])=1">SHALL contain exactly one [1..1] templateId (CONF:13182) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.82" (CONF:13183).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.2-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.2-errors-abstract" abstract="true">
      <sch:assert id="a-7130" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7130).</sch:assert>
      <sch:assert id="a-7131" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7131).</sch:assert>
      <sch:assert id="a-7133" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:7133).</sch:assert>
      <sch:assert id="a-7134" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:7134).</sch:assert>
      <sch:assert id="a-7137" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:7137).</sch:assert>
      <sch:assert id="a-7140" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:7140).</sch:assert>
      <sch:assert id="a-7143" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:7143).</sch:assert>
      <sch:assert id="a-14849" test="cda:statusCode[@code and @code=document('2.16.840.1.113883.11.20.9.39.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.39']/svs:ConceptList/svs:Concept/@code]">This statusCode SHALL contain exactly one [1..1] @code, which SHALL be selected from ValueSet Result Status 2.16.840.1.113883.11.20.9.39 STATIC (CONF:14849).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.2-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-errors-abstract" />
      <sch:assert id="a-9138" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.2'])=1">SHALL contain exactly one [1..1] templateId (CONF:7136) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.2" (CONF:9138).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.87-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.87-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-errors-abstract" />
      <sch:assert id="a-16701" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:16701).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.87-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.87']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.87-errors-abstract" />
      <sch:assert id="a-11673" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.87'])=1">SHALL contain exactly one [1..1] templateId (CONF:11672) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.87" (CONF:11673).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.91-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.91-errors-abstract" abstract="true">
      <sch:assert id="a-13276" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:13276).</sch:assert>
      <sch:assert id="a-13277" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13277).</sch:assert>
      <sch:assert id="a-13281" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:13281).</sch:assert>
      <sch:assert id="a-13282" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13282).</sch:assert>
      <sch:assert id="a-13284" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:13284).</sch:assert>
      <sch:assert id="a-13285" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13285).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.91-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.91']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.91-errors-abstract" />
      <sch:assert id="a-13279" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.91'])=1">SHALL contain exactly one [1..1] templateId (CONF:13278) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.91" (CONF:13279).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.93-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.93-errors-abstract" abstract="true">
      <sch:assert id="a-11879" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11879).</sch:assert>
      <sch:assert id="a-11880" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11880).</sch:assert>
      <sch:assert id="a-11884" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:11884).</sch:assert>
      <sch:assert id="a-11885" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11885).</sch:assert>
      <sch:assert id="a-11886" test="cda:code[@code='33999-4' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL contain exactly one [1..1] @code="33999-4" status (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:11886).</sch:assert>
      <sch:assert id="a-11887" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:11887).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.93-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.93']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.93-errors-abstract" />
      <sch:assert id="a-11882" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.93'])=1">SHALL contain exactly one [1..1] templateId (CONF:11881) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.93" (CONF:11882).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.38-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.38-errors-abstract" abstract="true">
      <sch:assert id="a-11705" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11705).</sch:assert>
      <sch:assert id="a-11706" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11706).</sch:assert>
      <sch:assert id="a-11707" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:11707).</sch:assert>
      <sch:assert id="a-11708" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11708).</sch:assert>
      <sch:assert id="a-11709" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11709).</sch:assert>
      <sch:assert id="a-11710" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11710).</sch:assert>
      <sch:assert id="a-11711" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11711).</sch:assert>
      <sch:assert id="a-11712" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:11712).</sch:assert>
      <sch:assert id="a-11713" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:11713).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.38-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.38']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.38-errors-abstract" />
      <sch:assert id="a-11722" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.38'])=1">SHALL contain exactly one [1..1] templateId (CONF:11721) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.38" (CONF:11722).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.16-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.16-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-errors-abstract" />
      <sch:assert id="a-11733" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11733).</sch:assert>
      <sch:assert id="a-11734" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11734).</sch:assert>
      <sch:assert id="a-11737" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:11737).</sch:assert>
      <sch:assert id="a-11738" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11738).</sch:assert>
      <sch:assert id="a-11739" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:11739).</sch:assert>
      <sch:assert id="a-11740" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11740).</sch:assert>
      <sch:assert id="a-11741" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11741).</sch:assert>
      <sch:assert id="a-11742" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11742).</sch:assert>
      <sch:assert id="a-11743" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:11743).</sch:assert>
      <sch:assert id="a-13879" test="count(cda:entryRelationship[@typeCode='CAUS'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.18'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:11745) such that it SHALL contain exactly one [1..1] @typeCode="CAUS" (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:11746). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:11747). SHALL contain exactly one [1..1] Diagnostic Study Performed (templateId:2.16.840.1.113883.10.20.24.3.18) (CONF:13879).</sch:assert>
      <sch:assert id="a-14572" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:14572).</sch:assert>
      <sch:assert id="a-16411" test="cda:value[@code='102460003' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="102460003" Decreased tolerance (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16411).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.16-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.16']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.16-errors-abstract" />
      <sch:assert id="a-11736" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.16'])=1">SHALL contain exactly one [1..1] templateId (CONF:11735) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.16" (CONF:11736).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.40-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.40-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-errors-abstract" />
      <sch:assert id="a-16697" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:16697).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.40-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.40']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.40-errors-abstract" />
      <sch:assert id="a-11766" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.40'])=1">SHALL contain exactly one [1..1] templateId (CONF:11765) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.40" (CONF:11766).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.15-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.15-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-errors-abstract" />
      <sch:assert id="a-11767" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11767).</sch:assert>
      <sch:assert id="a-11768" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11768).</sch:assert>
      <sch:assert id="a-11771" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:11771).</sch:assert>
      <sch:assert id="a-11772" test="count(cda:code[@code='ASSERTION'][@codeSystem='2.16.840.1.113883.5.4'])=1">SHALL contain exactly one [1..1] code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:11772).</sch:assert>
      <sch:assert id="a-11774" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11774).</sch:assert>
      <sch:assert id="a-11775" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11775).</sch:assert>
      <sch:assert id="a-11776" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11776).</sch:assert>
      <sch:assert id="a-11777" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:11777).</sch:assert>
      <sch:assert id="a-13836" test="count(cda:entryRelationship[@typeCode='CAUS'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.18'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:11779) such that it SHALL contain exactly one [1..1] @typeCode="CAUS" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:11780). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:11781). SHALL contain exactly one [1..1] Diagnostic Study Performed (templateId:2.16.840.1.113883.10.20.24.3.18) (CONF:13836).</sch:assert>
      <sch:assert id="a-16408" test="count(cda:value[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='281647001'][@codeSystem='2.16.840.1.113883.6.96'][@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value="281647001" Adverse reaction with @xsi:type="CD" (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16408).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.15-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.15']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.15-errors-abstract" />
      <sch:assert id="a-11770" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.15'])=1">SHALL contain exactly one [1..1] templateId (CONF:11769) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.15" (CONF:11770).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.39-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.39-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" />
      <sch:assert id="a-11793" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11793).</sch:assert>
      <sch:assert id="a-11797" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11797).</sch:assert>
      <sch:assert id="a-11798" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11798).</sch:assert>
      <sch:assert id="a-11799" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11799).</sch:assert>
      <sch:assert id="a-11814" test="count(cda:author)=1">SHALL contain exactly one [1..1] author (CONF:11814).</sch:assert>
      <sch:assert id="a-11815" test="cda:author[count(cda:time)=1]">This author SHALL contain exactly one [1..1] time (CONF:11815).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.39-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.39']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.39-errors-abstract" />
      <sch:assert id="a-11795" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.39'])=1">SHALL contain exactly one [1..1] templateId (CONF:11794) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.39" (CONF:11795).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.3-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.3-errors-abstract" abstract="true">
      <sch:assert id="a-11840" test="@classCode='ACT'">SHALL contain exactly one [1..1] @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:11840).</sch:assert>
      <sch:assert id="a-11841" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11841).</sch:assert>
      <sch:assert id="a-11845" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:11845).</sch:assert>
      <sch:assert id="a-11846" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11846).</sch:assert>
      <sch:assert id="a-11847" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11847).</sch:assert>
      <sch:assert id="a-11852" test="count(cda:participant[@typeCode='AUT'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CONF:11850) such that it SHALL contain exactly one [1..1] @typeCode="AUT" author (originator) (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:11851). SHALL contain exactly one [1..1] participantRole (CONF:11852).</sch:assert>
      <sch:assert id="a-11853" test="cda:participant[@typeCode='AUT']/cda:participantRole[count(cda:code[@code='158965000'][@codeSystem='2.16.840.1.113883.6.96'])=1]">This participantRole SHALL contain exactly one [1..1] code="158965000" Medical Practitioner (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:11853).</sch:assert>
      <sch:assert id="a-11858" test="count(cda:participant[@typeCode='IRCP'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CONF:11856) such that it SHALL contain exactly one [1..1] @typeCode="IRCP" information recipient  (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:11857). SHALL contain exactly one [1..1] participantRole (CONF:11858).</sch:assert>
      <sch:assert id="a-12101" test="cda:participant[@typeCode='AUT']/cda:participantRole[@classCode='ASSIGNED']">This participantRole SHALL contain exactly one [1..1] @classCode="ASSIGNED" assigned entity (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:12101).</sch:assert>
      <sch:assert id="a-12102" test="cda:participant[@typeCode='IRCP']/cda:participantRole[@classCode='PAT']">This participantRole SHALL contain exactly one [1..1] @classCode="PAT" patient (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:12102).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.3-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.3']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.3-errors-abstract" />
      <sch:assert id="a-11843" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.3'])=1">SHALL contain exactly one [1..1] templateId (CONF:11842) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.3" (CONF:11843).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.49-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.49-errors-abstract" abstract="true">
      <sch:assert id="a-8710" test="@classCode='ENC'">SHALL contain exactly one [1..1] @classCode="ENC" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8710).</sch:assert>
      <sch:assert id="a-8711" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:8711).</sch:assert>
      <sch:assert id="a-8713" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8713).</sch:assert>
      <sch:assert id="a-8715" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:8715).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.49-errors" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.49']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.49-errors-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.23-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.23-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.49-errors-abstract" />
      <sch:assert id="a-11864" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11864).</sch:assert>
      <sch:assert id="a-11874" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11874).</sch:assert>
      <sch:assert id="a-11875" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11875).</sch:assert>
      <sch:assert id="a-11876" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11876).</sch:assert>
      <sch:assert id="a-11877" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:11877).</sch:assert>
      <sch:assert id="a-11878" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:11878).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.23-errors" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.23-errors-abstract" />
      <sch:assert id="a-11862" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.23'])=1">SHALL contain exactly one [1..1] templateId (CONF:11861) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.23" (CONF:11862).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.21-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.21-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.49-errors-abstract" />
      <sch:assert id="a-11894" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11894).</sch:assert>
      <sch:assert id="a-11895" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11895).</sch:assert>
      <sch:assert id="a-11896" test="cda:statusCode[@code='active']">This statusCode SHALL contain exactly one [1..1] @code="active" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11896).</sch:assert>
      <sch:assert id="a-11898" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11898).</sch:assert>
      <sch:assert id="a-11899" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:11899).</sch:assert>
      <sch:assert id="a-11900" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:11900).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.21-errors" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.21']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.21-errors-abstract" />
      <sch:assert id="a-11889" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.21'])=1">SHALL contain exactly one [1..1] templateId (CONF:11888) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.21" (CONF:11889).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.40-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.40-errors-abstract" abstract="true">
      <sch:assert id="a-8564" test="@classCode='ENC'">SHALL contain exactly one [1..1] @classCode="ENC" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8564).</sch:assert>
      <sch:assert id="a-8565" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.23.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.23']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet Plan of Care moodCode (Act/Encounter/Procedure) 2.16.840.1.113883.11.20.9.23 STATIC 2011-09-30 (CONF:8565).</sch:assert>
      <sch:assert id="a-8567" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8567).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.40-errors" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.40']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.40-errors-abstract" />
      <sch:assert id="a-10511" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.40'])=1">SHALL contain exactly one [1..1] templateId (CONF:8566) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.40" (CONF:10511).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.24-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.24-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.40-errors-abstract" />
      <sch:assert id="a-11911" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11911).</sch:assert>
      <sch:assert id="a-11915" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11915).</sch:assert>
      <sch:assert id="a-11916" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11916).</sch:assert>
      <sch:assert id="a-11917" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11917).</sch:assert>
      <sch:assert id="a-11918" test="count(cda:author)=1">SHALL contain exactly one [1..1] author (CONF:11918).</sch:assert>
      <sch:assert id="a-11919" test="cda:author[count(cda:time)=1]">This author SHALL contain exactly one [1..1] time (CONF:11919).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.24-errors" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.24']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.24-errors-abstract" />
      <sch:assert id="a-11913" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.24'])=1">SHALL contain exactly one [1..1] templateId (CONF:11912) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.24" (CONF:11913).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.22-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.22-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.40-errors-abstract" />
      <sch:assert id="a-11932" test="@moodCode='RQO'">SHALL contain exactly one [1..1] @moodCode="RQO" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11932).</sch:assert>
      <sch:assert id="a-11936" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11936).</sch:assert>
      <sch:assert id="a-11937" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11937).</sch:assert>
      <sch:assert id="a-11938" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11938).</sch:assert>
      <sch:assert id="a-11939" test="count(cda:author)=1">SHALL contain exactly one [1..1] author (CONF:11939).</sch:assert>
      <sch:assert id="a-11940" test="cda:author[count(cda:time)=1]">This author SHALL contain exactly one [1..1] time (CONF:11940).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.22-errors" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.22']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.22-errors-abstract" />
      <sch:assert id="a-11934" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.22'])=1">SHALL contain exactly one [1..1] templateId (CONF:11933) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.22" (CONF:11934).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.37-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.37-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" />
      <sch:assert id="a-11953" test="@moodCode='RQO'">SHALL contain exactly one [1..1] @moodCode="RQO" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:11953).</sch:assert>
      <sch:assert id="a-11957" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11957).</sch:assert>
      <sch:assert id="a-11958" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:11958).</sch:assert>
      <sch:assert id="a-11959" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:11959).</sch:assert>
      <sch:assert id="a-11962" test="count(cda:author[count(cda:time)=1])=1">SHALL contain exactly one [1..1] author (CONF:11961) such that it SHALL contain exactly one [1..1] time (CONF:11962).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.37-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.37']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.37-errors-abstract" />
      <sch:assert id="a-11955" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.37'])=1">SHALL contain exactly one [1..1] templateId (CONF:11954) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.37" (CONF:11955).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.4-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.4-errors-abstract" abstract="true">
      <sch:assert id="a-9041" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:9041).</sch:assert>
      <sch:assert id="a-9042" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:9042).</sch:assert>
      <sch:assert id="a-9043" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:9043).</sch:assert>
      <sch:assert id="a-9045" test="count(cda:code[@code=document('2.16.840.1.113883.3.88.12.3221.7.2.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.3.88.12.3221.7.2']/svs:ConceptList/svs:Concept/@code])=1">SHALL contain exactly one [1..1] code, which SHOULD be selected from ValueSet Problem Type 2.16.840.1.113883.3.88.12.3221.7.2 STATIC 2012-06-01 (CONF:9045).</sch:assert>
      <sch:assert id="a-9049" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:9049).</sch:assert>
      <sch:assert id="a-9058" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD", where the @code SHOULD be selected from ValueSet Problem 2.16.840.1.113883.3.88.12.3221.7.4 DYNAMIC (CONF:9058).</sch:assert>
      <sch:assert id="a-19112" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19112).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.4-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.4']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-errors-abstract" />
      <sch:assert id="a-14927" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.4'])=1">SHALL contain exactly one [1..1] templateId (CONF:14926) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.4" (CONF:14927).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.11-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.11-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-errors-abstract" />
      <sch:assert id="a-11980" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:11980).</sch:assert>
      <sch:assert id="a-11983" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:11983).</sch:assert>
      <sch:assert id="a-11984" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:11984).</sch:assert>
      <sch:assert id="a-11985" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:11985).</sch:assert>
      <sch:assert id="a-11995" test="cda:code[@code='282291009' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="282291009	" diagnosis (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:11995).</sch:assert>
      <sch:assert id="a-12008" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:12008).</sch:assert>
      <sch:assert id="a-12010" test="not(cda:value[@xsi:type='CD']/cda:qualifier) or cda:value[@xsi:type='CD']/cda:qualifier[count(cda:name)=1]">The qualifier, if present, SHALL contain exactly one [1..1] name (CONF:12010).</sch:assert>
      <sch:assert id="a-12011" test="not(cda:value[@xsi:type='CD']/cda:qualifier) or cda:value[@xsi:type='CD']/cda:qualifier[count(cda:value)=1]">The qualifier, if present, SHALL contain exactly one [1..1] value (CONF:12011).</sch:assert>
      <sch:assert id="a-12012" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12012).</sch:assert>
      <sch:assert id="a-12253" test="count(cda:entryRelationship[@typeCode='REFR'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.94'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:11975) such that it SHALL contain exactly one [1..1] @typeCode="REFR" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:11979). SHALL contain exactly one [1..1] Problem Status Active (templateId:2.16.840.1.113883.10.20.24.3.94) (CONF:12253).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.11-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.11-errors-abstract" />
      <sch:assert id="a-11973" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.11'])=1">SHALL contain exactly one [1..1] templateId (CONF:11972) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.11" (CONF:11973).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.13-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.13-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-errors-abstract" />
      <sch:assert id="a-12024" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12024).</sch:assert>
      <sch:assert id="a-12025" test="cda:code[@code='282291009' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="282291009" diagnosis (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12025).</sch:assert>
      <sch:assert id="a-12028" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12028).</sch:assert>
      <sch:assert id="a-12029" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:12029).</sch:assert>
      <sch:assert id="a-12030" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:12030).</sch:assert>
      <sch:assert id="a-12043" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:12043).</sch:assert>
      <sch:assert id="a-12047" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12047).</sch:assert>
      <sch:assert id="a-12219" test="count(cda:entryRelationship[@typeCode='REFR'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.95'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:12019) such that it SHALL contain exactly one [1..1] @typeCode="REFR" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:12023). SHALL contain exactly one [1..1] Problem Status Inactive (templateId:2.16.840.1.113883.10.20.24.3.95) (CONF:12219).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.13-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.13']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.13-errors-abstract" />
      <sch:assert id="a-12017" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.13'])=1">SHALL contain exactly one [1..1] templateId (CONF:12016) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.13" (CONF:12017).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.14-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.14-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-errors-abstract" />
      <sch:assert id="a-12059" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12059).</sch:assert>
      <sch:assert id="a-12060" test="cda:code[@code='282291009' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="282291009	" diagnosis (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12060).</sch:assert>
      <sch:assert id="a-12061" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12061).</sch:assert>
      <sch:assert id="a-12062" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:12062).</sch:assert>
      <sch:assert id="a-12063" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:12063).</sch:assert>
      <sch:assert id="a-12076" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:12076).</sch:assert>
      <sch:assert id="a-12077" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12077).</sch:assert>
      <sch:assert id="a-12313" test="count(cda:entryRelationship[@typeCode='REFR'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.96'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:12054) such that it SHALL contain exactly one [1..1] @typeCode="REFR" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:12058). SHALL contain exactly one [1..1] Problem Status Resolved (templateId:2.16.840.1.113883.10.20.24.3.96) (CONF:12313).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.14-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.14']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.14-errors-abstract" />
      <sch:assert id="a-12052" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.14'])=1">SHALL contain exactly one [1..1] templateId (CONF:12051) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.14" (CONF:12052).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.16-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.16-errors-abstract" abstract="true">
      <sch:assert id="a-7496" test="@classCode='SBADM'">SHALL contain exactly one [1..1] @classCode="SBADM" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7496).</sch:assert>
      <sch:assert id="a-7497" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.18.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.18']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet MoodCodeEvnInt 2.16.840.1.113883.11.20.9.18 STATIC 2011-04-03 (CONF:7497).</sch:assert>
      <sch:assert id="a-7500" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:7500).</sch:assert>
      <sch:assert id="a-7507" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:7507).</sch:assert>
      <sch:assert id="a-7511" test="count(cda:effectiveTime[count(cda:high)=1][count(cda:low)=1])=1">SHALL contain exactly one [1..1] effectiveTime (CONF:7508) such that it SHALL contain exactly one [1..1] low (CONF:7511).</sch:assert>
      <sch:assert id="a-7512" test="count(cda:effectiveTime[count(cda:low)=1][count(cda:high)=1])=1">SHALL contain exactly one [1..1] effectiveTime (CONF:7508) such that it SHALL contain exactly one [1..1] high (CONF:7512).</sch:assert>
      <sch:assert id="a-7520" test="count(cda:consumable)=1">SHALL contain exactly one [1..1] consumable (CONF:7520).</sch:assert>
      <sch:assert id="a-16085" test="cda:consumable[count(cda:manufacturedProduct[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.23'])=1]">This consumable SHALL contain exactly one [1..1] Medication Information (templateId:2.16.840.1.113883.10.20.22.4.23) (CONF:16085).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.16-errors" context="cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.16']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.16-errors-abstract" />
      <sch:assert id="a-10504" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.16'])=1">SHALL contain exactly one [1..1] templateId (CONF:7499) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.16" (CONF:10504).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.41-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.41-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.16-errors-abstract" />
      <sch:assert id="a-12081" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12081).</sch:assert>
      <sch:assert id="a-12412" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:12412).</sch:assert>
      <sch:assert id="a-12413" test="cda:statusCode[@code='active']">This statusCode SHALL contain exactly one [1..1] @code="active" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12413).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.41-errors" context="cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.41']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.41-errors-abstract" />
      <sch:assert id="a-12083" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.41'])=1">SHALL contain exactly one [1..1] templateId (CONF:12082) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.41" (CONF:12083).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.90-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.90-errors-abstract" abstract="true">
      <sch:assert id="a-16303" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:16303).</sch:assert>
      <sch:assert id="a-16304" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:16304).</sch:assert>
      <sch:assert id="a-16307" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:16307).</sch:assert>
      <sch:assert id="a-16308" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:16308).</sch:assert>
      <sch:assert id="a-16309" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:16309).</sch:assert>
      <sch:assert id="a-16312" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:16312).</sch:assert>
      <sch:assert id="a-16317" test="cda:value[@code]">This value SHALL contain exactly one [1..1] @code, which SHALL be selected from ValueSet Allergy/Adverse Event Type 2.16.840.1.113883.3.88.12.3221.6.2 DYNAMIC (CONF:16317).</sch:assert>
      <sch:assert id="a-16344" test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.8'])=1]) &lt; 2">SHALL contain zero or one [0..1] entryRelationship (CONF:16341) such that it SHALL contain exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:16342). SHALL contain exactly one [1..1] @inversionInd="true" True (CONF:16343). SHALL contain exactly one [1..1] Severity Observation (templateId:2.16.840.1.113883.10.20.22.4.8) (CONF:16344).</sch:assert>
      <sch:assert id="a-16345" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:16345).</sch:assert>
      <sch:assert id="a-16346" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:16346).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.90-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.90']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.90-errors-abstract" />
      <sch:assert id="a-16306" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.90'])=1">SHALL contain exactly one [1..1] templateId (CONF:16305) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.90" (CONF:16306).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.5-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.5-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.90-errors-abstract" />
      <sch:assert id="a-12104" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12104).</sch:assert>
      <sch:assert id="a-12105" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12105).</sch:assert>
      <sch:assert id="a-12107" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:12107).</sch:assert>
      <sch:assert id="a-12108" test="count(cda:code[@code='ASSERTION'][@codeSystem='2.16.840.1.113883.5.4'])=1">SHALL contain exactly one [1..1] code="ASSERTION" (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:12108).</sch:assert>
      <sch:assert id="a-12109" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12109).</sch:assert>
      <sch:assert id="a-12110" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12110).</sch:assert>
      <sch:assert id="a-12111" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:12111).</sch:assert>
      <sch:assert id="a-12114" test="count(cda:participant[@typeCode='PRD'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:12112) such that it SHALL contain exactly one [1..1] @typeCode="PRD" product (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:12113). SHALL contain exactly one [1..1] participantRole (CONF:12114).</sch:assert>
      <sch:assert id="a-12115" test="cda:participant[@typeCode='PRD']/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" manufactured product (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:12115).</sch:assert>
      <sch:assert id="a-12116" test="cda:participant[@typeCode='PRD']/cda:participantRole[count(cda:playingDevice)=1]">This participantRole SHALL contain exactly one [1..1] playingDevice (CONF:12116).</sch:assert>
      <sch:assert id="a-12117" test="cda:participant[@typeCode='PRD']/cda:participantRole/cda:playingDevice[@classCode]">This playingDevice SHALL contain exactly one [1..1] @classCode (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:12117).</sch:assert>
      <sch:assert id="a-12118" test="cda:participant[@typeCode='PRD']/cda:participantRole/cda:playingDevice[count(cda:code)=1]">This playingDevice SHALL contain exactly one [1..1] code (CONF:12118).</sch:assert>
      <sch:assert id="a-12124" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:12119) such that it SHALL contain exactly one [1..1] @typeCode="MFST" is manifestation of (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:12122). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:12123). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:12124).</sch:assert>
      <sch:assert id="a-12189" test="cda:value[@code='281647001' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="281647001" adverse reaction, which SHALL be selected from CodeSystem SNOMED-CT (2.16.840.1.113883.6.96) STATIC (CONF:12189).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.5-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.5']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.5-errors-abstract" />
     
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.6-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.6-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.90-errors-abstract" />
      <sch:assert id="a-12132" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12132).</sch:assert>
      <sch:assert id="a-12133" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12133).</sch:assert>
      <sch:assert id="a-12136" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:12136).</sch:assert>
      <sch:assert id="a-12137" test="count(cda:code[@code='ASSERTION'][@codeSystem='2.16.840.1.113883.5.4'])=1">SHALL contain exactly one [1..1] code="ASSERTION" (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:12137).</sch:assert>
      <sch:assert id="a-12138" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12138).</sch:assert>
      <sch:assert id="a-12139" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12139).</sch:assert>
      <sch:assert id="a-12140" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:12140).</sch:assert>
      <sch:assert id="a-12143" test="count(cda:participant[@typeCode='PRD'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:12141) such that it SHALL contain exactly one [1..1] @typeCode="PRD" product (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:12142). SHALL contain exactly one [1..1] participantRole (CONF:12143).</sch:assert>
      <sch:assert id="a-12144" test="cda:participant[@typeCode='PRD']/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" manufactured product (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:12144).</sch:assert>
      <sch:assert id="a-12145" test="cda:participant[@typeCode='PRD']/cda:participantRole[count(cda:playingDevice)=1]">This participantRole SHALL contain exactly one [1..1] playingDevice (CONF:12145).</sch:assert>
      <sch:assert id="a-12146" test="cda:participant[@typeCode='PRD']/cda:participantRole/cda:playingDevice[@classCode='DEV']">This playingDevice SHALL contain exactly one [1..1] @classCode="DEV" device (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:12146).</sch:assert>
      <sch:assert id="a-12147" test="cda:participant[@typeCode='PRD']/cda:participantRole/cda:playingDevice[count(cda:code)=1]">This playingDevice SHALL contain exactly one [1..1] code (CONF:12147).</sch:assert>
      <sch:assert id="a-12151" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:12148) such that it SHALL contain exactly one [1..1] @typeCode="MFST" is manifestation of (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:12149). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:12150). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:12151).</sch:assert>
      <sch:assert id="a-12188" test="cda:value[@code='106190000' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="106190000" allergy, which SHALL be selected from CodeSystem SNOMED-CT (2.16.840.1.113883.6.96) STATIC (CONF:12188).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.6-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.6']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.6-errors-abstract" />
      
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.8-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.8-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.90-errors-abstract" />
      <sch:assert id="a-12160" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12160).</sch:assert>
      <sch:assert id="a-12161" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12161).</sch:assert>
      <sch:assert id="a-12164" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:12164).</sch:assert>
      <sch:assert id="a-12165" test="count(cda:code[@code='ASSERTION'][@codeSystem='2.16.840.1.113883.5.4'])=1">SHALL contain exactly one [1..1] code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:12165).</sch:assert>
      <sch:assert id="a-12166" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12166).</sch:assert>
      <sch:assert id="a-12167" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12167).</sch:assert>
      <sch:assert id="a-12172" test="count(cda:participant[@typeCode='PRD'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:12170) such that it SHALL contain exactly one [1..1] @typeCode="PRD" product (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:12171). SHALL contain exactly one [1..1] participantRole (CONF:12172).</sch:assert>
      <sch:assert id="a-12173" test="cda:participant[@typeCode='PRD']/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" manufactured product (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:12173).</sch:assert>
      <sch:assert id="a-12174" test="cda:participant[@typeCode='PRD']/cda:participantRole[count(cda:playingDevice)=1]">This participantRole SHALL contain exactly one [1..1] playingDevice (CONF:12174).</sch:assert>
      <sch:assert id="a-12175" test="cda:participant[@typeCode='PRD']/cda:participantRole/cda:playingDevice[@classCode='DEV']">This playingDevice SHALL contain exactly one [1..1] @classCode="DEV" device (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:12175).</sch:assert>
      <sch:assert id="a-12176" test="cda:participant[@typeCode='PRD']/cda:participantRole/cda:playingDevice[count(cda:code)=1]">This playingDevice SHALL contain exactly one [1..1] code (CONF:12176).</sch:assert>
      <sch:assert id="a-12342" test="count(cda:value[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='102460003'][@codeSystem='2.16.840.1.113883.6.96'][@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value="102460003" Decreased tolerance with @xsi:type="CD" (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12342).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.8-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.8']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.8-errors-abstract" />
     
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.6-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.6-errors-abstract" abstract="true">
      <sch:assert id="a-7357" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7357).</sch:assert>
      <sch:assert id="a-7358" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7358).</sch:assert>
      <sch:assert id="a-7364" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:7364).</sch:assert>
      <sch:assert id="a-7365" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet HITSPProblemStatus 2.16.840.1.113883.3.88.12.80.68 DYNAMIC (CONF:7365).</sch:assert>
      <sch:assert id="a-19113" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19113).</sch:assert>
      <sch:assert id="a-19162" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:19162).</sch:assert>
      <sch:assert id="a-19163" test="cda:code[@code='33999-4' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL contain exactly one [1..1] @code="33999-4" Status (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:19163).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.6-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.6']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.6-errors-abstract" />
      <sch:assert id="a-10518" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.6'])=1">SHALL contain exactly one [1..1] templateId (CONF:7359) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.6" (CONF:10518).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.94-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.94-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.6-errors-abstract" />
      <sch:assert id="a-12207" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:12207).</sch:assert>
      <sch:assert id="a-12214" test="cda:value[@code='55561003' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="55561003" active (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12214).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.94-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.94']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.94-errors-abstract" />
      <sch:assert id="a-12213" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.94'])=1">SHALL contain exactly one [1..1] templateId (CONF:12212) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.94" (CONF:12213).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.95-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.95-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.6-errors-abstract" />
      <sch:assert id="a-12208" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:12208).</sch:assert>
      <sch:assert id="a-12211" test="cda:value[@code='73425007' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="73425007" inactive (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12211).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.95-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.95']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.95-errors-abstract" />
      <sch:assert id="a-12210" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.95'])=1">SHALL contain exactly one [1..1] templateId (CONF:12209) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.95" (CONF:12210).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.96-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.96-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.6-errors-abstract" />
      <sch:assert id="a-12215" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:12215).</sch:assert>
      <sch:assert id="a-12216" test="cda:value[@code='413322009' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="413322009" resolved (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12216).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.96-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.96']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.96-errors-abstract" />
      <sch:assert id="a-12218" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.96'])=1">SHALL contain exactly one [1..1] templateId (CONF:12217) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.96" (CONF:12218).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.76-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.76-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-errors-abstract" />
      <sch:assert id="a-12259" test="count(cda:entryRelationship[@typeCode='REFR'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.94'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:12257) such that it SHALL contain exactly one [1..1] @typeCode="REFR" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:12258). SHALL contain exactly one [1..1] Problem Status Active (templateId:2.16.840.1.113883.10.20.24.3.94) (CONF:12259).</sch:assert>
      <sch:assert id="a-12260" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12260).</sch:assert>
      <sch:assert id="a-12261" test="cda:code[@code='418799008' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="418799008" symptom (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12261).</sch:assert>
      <sch:assert id="a-12262" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12262).</sch:assert>
      <sch:assert id="a-12263" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:12263).</sch:assert>
      <sch:assert id="a-12264" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:12264).</sch:assert>
      <sch:assert id="a-12281" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12281).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.76-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.76']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.76-errors-abstract" />
      <sch:assert id="a-12255" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.76'])=1">SHALL contain exactly one [1..1] templateId (CONF:12254) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.76" (CONF:12255).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.78-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.78-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-errors-abstract" />
      <sch:assert id="a-12290" test="count(cda:entryRelationship[@typeCode='REFR'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.95'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:12288) such that it SHALL contain exactly one [1..1] @typeCode="REFR" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:12289). SHALL contain exactly one [1..1] Problem Status Inactive (templateId:2.16.840.1.113883.10.20.24.3.95) (CONF:12290).</sch:assert>
      <sch:assert id="a-12291" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12291).</sch:assert>
      <sch:assert id="a-12292" test="cda:code[@code='418799008' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="418799008" symptom (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12292).</sch:assert>
      <sch:assert id="a-12293" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12293).</sch:assert>
      <sch:assert id="a-12294" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:12294).</sch:assert>
      <sch:assert id="a-12295" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:12295).</sch:assert>
      <sch:assert id="a-12309" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12309).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.78-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.78']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.78-errors-abstract" />
      <sch:assert id="a-12286" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.78'])=1">SHALL contain exactly one [1..1] templateId (CONF:12285) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.78" (CONF:12286).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.79-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.79-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-errors-abstract" />
      <sch:assert id="a-12319" test="count(cda:entryRelationship[@typeCode='REFR'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.96'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:12317) such that it SHALL contain exactly one [1..1] @typeCode="REFR" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:12318). SHALL contain exactly one [1..1] Problem Status Resolved (templateId:2.16.840.1.113883.10.20.24.3.96) (CONF:12319).</sch:assert>
      <sch:assert id="a-12320" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12320).</sch:assert>
      <sch:assert id="a-12321" test="cda:code[@code='418799008' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="418799008" symptom (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12321).</sch:assert>
      <sch:assert id="a-12322" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12322).</sch:assert>
      <sch:assert id="a-12323" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:12323).</sch:assert>
      <sch:assert id="a-12324" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:12324).</sch:assert>
      <sch:assert id="a-12338" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12338).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.79-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.79']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.79-errors-abstract" />
      <sch:assert id="a-12315" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.79'])=1">SHALL contain exactly one [1..1] templateId (CONF:12314) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.79" (CONF:12315).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.43-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.43-errors-abstract" abstract="true">
      <sch:assert id="a-8577" test="@classCode='SPLY'">SHALL contain exactly one [1..1] @classCode="SPLY" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8577).</sch:assert>
      <sch:assert id="a-8578" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.24.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.24']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet Plan of Care moodCode (SubstanceAdministration/Supply) 2.16.840.1.113883.11.20.9.24 STATIC 2011-09-30 (CONF:8578).</sch:assert>
      <sch:assert id="a-8580" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8580).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.43-errors" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.43']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.43-errors-abstract" />
      <sch:assert id="a-10515" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.43'])=1">SHALL contain exactly one [1..1] templateId (CONF:8579) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.43" (CONF:10515).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.9-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.9-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.43-errors-abstract" />
      <sch:assert id="a-12343" test="@moodCode='RQO'">SHALL contain exactly one [1..1] @moodCode="RQO" request, which SHALL be selected from CodeSystem ActMood (2.16.840.1.113883.5.1001) STATIC (CONF:12343).</sch:assert>
      <sch:assert id="a-12348" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12348).</sch:assert>
      <sch:assert id="a-12351" test="count(cda:participant[@typeCode='DEV'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CONF:12349) such that it SHALL contain exactly one [1..1] @typeCode="DEV" device, which SHALL be selected from CodeSystem HL7ParticipationType (2.16.840.1.113883.5.90) STATIC (CONF:12350). SHALL contain exactly one [1..1] participantRole (CONF:12351).</sch:assert>
      <sch:assert id="a-12352" test="cda:participant[@typeCode='DEV']/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" manufactured product, which SHALL be selected from CodeSystem RoleClass (2.16.840.1.113883.5.110) STATIC (CONF:12352).</sch:assert>
      <sch:assert id="a-12353" test="cda:participant[@typeCode='DEV']/cda:participantRole[count(cda:playingDevice)=1]">This participantRole SHALL contain exactly one [1..1] playingDevice (CONF:12353).</sch:assert>
      <sch:assert id="a-12354" test="cda:participant[@typeCode='DEV']/cda:participantRole/cda:playingDevice[@classCode='DEV']">This playingDevice SHALL contain exactly one [1..1] @classCode="DEV" device, which SHALL be selected from CodeSystem HL7ParticipationType (2.16.840.1.113883.5.90) STATIC (CONF:12354).</sch:assert>
      <sch:assert id="a-12355" test="cda:participant[@typeCode='DEV']/cda:participantRole/cda:playingDevice[count(cda:code)=1]">This playingDevice SHALL contain exactly one [1..1] code (CONF:12355).</sch:assert>
      <sch:assert id="a-13035" test="count(cda:statusCode[@code='new'])=1">SHALL contain exactly one [1..1] statusCode="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13035).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.9-errors" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.9']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.9-errors-abstract" />
      <sch:assert id="a-12345" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.9'])=1">SHALL contain exactly one [1..1] templateId (CONF:12344) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.9" (CONF:12345).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.10-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.10-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.43-errors-abstract" />
      <sch:assert id="a-12368" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" intent, which SHALL be selected from CodeSystem ActMood (2.16.840.1.113883.5.1001) STATIC (CONF:12368).</sch:assert>
      <sch:assert id="a-12373" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12373).</sch:assert>
      <sch:assert id="a-12376" test="count(cda:participant[@typeCode='DEV'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CONF:12374) such that it SHALL contain exactly one [1..1] @typeCode="DEV" device, which SHALL be selected from CodeSystem HL7ParticipationType (2.16.840.1.113883.5.90) STATIC (CONF:12375). SHALL contain exactly one [1..1] participantRole (CONF:12376).</sch:assert>
      <sch:assert id="a-12377" test="cda:participant[@typeCode='DEV']/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" manufactured product, which SHALL be selected from CodeSystem RoleClass (2.16.840.1.113883.5.110) STATIC (CONF:12377).</sch:assert>
      <sch:assert id="a-12378" test="cda:participant[@typeCode='DEV']/cda:participantRole[count(cda:playingDevice)=1]">This participantRole SHALL contain exactly one [1..1] playingDevice (CONF:12378).</sch:assert>
      <sch:assert id="a-12379" test="cda:participant[@typeCode='DEV']/cda:participantRole/cda:playingDevice[@classCode='DEV']">This playingDevice SHALL contain exactly one [1..1] @classCode="DEV" device, which SHALL be selected from CodeSystem HL7ParticipationType (2.16.840.1.113883.5.90) STATIC (CONF:12379).</sch:assert>
      <sch:assert id="a-12380" test="cda:participant[@typeCode='DEV']/cda:participantRole/cda:playingDevice[count(cda:code)=1]">This playingDevice SHALL contain exactly one [1..1] code (CONF:12380).</sch:assert>
      <sch:assert id="a-13036" test="count(cda:statusCode[@code='new'])=1">SHALL contain exactly one [1..1] statusCode="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13036).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.10-errors" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.10']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.10-errors-abstract" />
      <sch:assert id="a-12370" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.10'])=1">SHALL contain exactly one [1..1] templateId (CONF:12369) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.10" (CONF:12370).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.7-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.7-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.14-errors-abstract" />
      <sch:assert id="a-12390" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" event, which SHALL be selected from CodeSystem ActMood (2.16.840.1.113883.5.1001) STATIC (CONF:12390).</sch:assert>
      <sch:assert id="a-12394" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed", which SHALL be selected from CodeSystem ActStatus (2.16.840.1.113883.5.14) STATIC (CONF:12394).</sch:assert>
      <sch:assert id="a-12395" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12395).</sch:assert>
      <sch:assert id="a-12398" test="count(cda:participant[@typeCode='DEV'][count(cda:participantRole)=1])=1">SHALL contain exactly one [1..1] participant (CONF:12396) such that it SHALL contain exactly one [1..1] @typeCode="DEV" device, which SHALL be selected from CodeSystem HL7ParticipationType (2.16.840.1.113883.5.90) STATIC (CONF:12397). SHALL contain exactly one [1..1] participantRole (CONF:12398).</sch:assert>
      <sch:assert id="a-12399" test="cda:participant[@typeCode='DEV']/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" manufactured product, which SHALL be selected from CodeSystem RoleClass (2.16.840.1.113883.5.110) STATIC (CONF:12399).</sch:assert>
      <sch:assert id="a-12400" test="cda:participant[@typeCode='DEV']/cda:participantRole[count(cda:playingDevice)=1]">This participantRole SHALL contain exactly one [1..1] playingDevice (CONF:12400).</sch:assert>
      <sch:assert id="a-12401" test="cda:participant[@typeCode='DEV']/cda:participantRole/cda:playingDevice[@classCode='DEV']">This playingDevice SHALL contain exactly one [1..1] @classCode="DEV" device, which SHALL be selected from CodeSystem HL7ParticipationType (2.16.840.1.113883.5.90) STATIC (CONF:12401).</sch:assert>
      <sch:assert id="a-12402" test="cda:participant[@typeCode='DEV']/cda:participantRole/cda:playingDevice[count(cda:code)=1]">This playingDevice SHALL contain exactly one [1..1] code (CONF:12402).</sch:assert>
      <sch:assert id="a-12414" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12414).</sch:assert>
      <sch:assert id="a-12415" test="cda:code[@code='360030002' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="360030002" application of device, which SHALL be selected from CodeSystem SNOMED-CT (2.16.840.1.113883.6.96) STATIC (CONF:12415).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.7-errors" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.7']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.7-errors-abstract" />
      <sch:assert id="a-12392" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.7'])=1">SHALL contain exactly one [1..1] templateId (CONF:12391) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.7" (CONF:12392).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.42-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.42-errors-abstract" abstract="true">
      <sch:assert id="a-12444" test="@classCode='ACT'">SHALL contain exactly one [1..1] @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12444).</sch:assert>
      <sch:assert id="a-12445" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12445).</sch:assert>
      <sch:assert id="a-12448" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:12448).</sch:assert>
      <sch:assert id="a-12449" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12449).</sch:assert>
      <sch:assert id="a-12450" test="cda:code[@code='416118004' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="416118004" administration (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:12450).</sch:assert>
      <sch:assert id="a-12452" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:12452).</sch:assert>
      <sch:assert id="a-12453" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12453).</sch:assert>
      <sch:assert id="a-12456" test="count(cda:entryRelationship[@typeCode='COMP'][count(cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.16'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:12454) such that it SHALL contain exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:12455). SHALL contain exactly one [1..1] Medication Activity (templateId:2.16.840.1.113883.10.20.22.4.16) (CONF:12456).</sch:assert>
      <sch:assert id="a-12457" test="cda:entryRelationship[@typeCode='COMP']/cda:substanceAdministration[@moodCode='EVN']">This substanceAdministration SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12457).</sch:assert>
      <sch:assert id="a-13241" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13241).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.42-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.42']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.42-errors-abstract" />
      <sch:assert id="a-12447" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.42'])=1">SHALL contain exactly one [1..1] templateId (CONF:12446) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.42" (CONF:12447).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.48-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.48-errors-abstract" abstract="true">
      <sch:assert id="a-12464" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" observation, which SHALL be selected from CodeSystem HL7ActClass (2.16.840.1.113883.5.6) STATIC (CONF:12464).</sch:assert>
      <sch:assert id="a-12465" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" event, which SHALL be selected from CodeSystem ActMood (2.16.840.1.113883.5.1001) STATIC (CONF:12465).</sch:assert>
      <sch:assert id="a-12469" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:12469).</sch:assert>
      <sch:assert id="a-12470" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12470).</sch:assert>
      <sch:assert id="a-12471" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed", which SHALL be selected from CodeSystem ActStatus (2.16.840.1.113883.5.14) STATIC (CONF:12471).</sch:assert>
      <sch:assert id="a-12472" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12472).</sch:assert>
      <sch:assert id="a-13037" test="cda:code[@code='406193000' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="406193000" patient satisfaction (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:13037).</sch:assert>
      <sch:assert id="a-13038" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:13038).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.48-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.48']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.48-errors-abstract" />
      <sch:assert id="a-12467" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.48'])=1">SHALL contain exactly one [1..1] templateId (CONF:12466) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.48" (CONF:12467).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.67-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.67-errors-abstract" abstract="true">
      <sch:assert id="a-12479" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" observation, which SHALL be selected from CodeSystem HL7ActClass (2.16.840.1.113883.5.6) STATIC (CONF:12479).</sch:assert>
      <sch:assert id="a-12480" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" event, which SHALL be selected from CodeSystem ActMood (2.16.840.1.113883.5.1001) STATIC (CONF:12480).</sch:assert>
      <sch:assert id="a-12484" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:12484).</sch:assert>
      <sch:assert id="a-12485" test="count(cda:code[@code='405193005'][@codeSystem='2.16.840.1.113883.6.96'])=1">SHALL contain exactly one [1..1] code="405193005" caregiver satisfaction, which SHALL be selected from CodeSystem SNOMED-CT (2.16.840.1.113883.6.96) STATIC (CONF:12485).</sch:assert>
      <sch:assert id="a-12486" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed", which SHALL be selected from CodeSystem ActStatus (2.16.840.1.113883.5.14) STATIC (CONF:12486).</sch:assert>
      <sch:assert id="a-12487" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12487).</sch:assert>
      <sch:assert id="a-12490" test="count(cda:entryRelationship[@typeCode='RSON'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.83'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:12488) such that it SHALL contain exactly one [1..1] @typeCode="RSON" has reason, which SHALL be selected from CodeSystem HL7ParticipationType (2.16.840.1.113883.5.90) STATIC (CONF:12489). SHALL contain exactly one [1..1] Patient Preference (templateId:2.16.840.1.113883.10.20.24.3.83) (CONF:12490).</sch:assert>
      <sch:assert id="a-12493" test="count(cda:entryRelationship[@typeCode='RSON'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.84'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:12491) such that it SHALL contain exactly one [1..1] @typeCode="RSON" has reason, which SHALL be selected from CodeSystem HL7ParticipationType (2.16.840.1.113883.5.90) STATIC (CONF:12492). SHALL contain exactly one [1..1] Provider Preference (templateId:2.16.840.1.113883.10.20.24.3.84) (CONF:12493).</sch:assert>
      <sch:assert id="a-12572" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:12572).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.67-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.67']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.67-errors-abstract" />
      <sch:assert id="a-12482" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.67'])=1">SHALL contain exactly one [1..1] templateId (CONF:12481) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.67" (CONF:12482).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.69-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.69-errors-abstract" abstract="true">
      <sch:assert id="a-14434" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:14434).</sch:assert>
      <sch:assert id="a-14435" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:14435).</sch:assert>
      <sch:assert id="a-14438" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:14438).</sch:assert>
      <sch:assert id="a-14439" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:14439).</sch:assert>
      <sch:assert id="a-14444" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:14444).</sch:assert>
      <sch:assert id="a-14445" test="count(cda:effectiveTime)=1">Represents clinically effective time of the measurement, which may be when the measurement was performed (e.g., a BP measurement), or may be when sample was taken (and measured some time afterwards) 
SHALL contain exactly one [1..1] effectiveTime (CONF:14445).</sch:assert>
      <sch:assert id="a-14450" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:14450).</sch:assert>
      <sch:assert id="a-19088" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19088).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.69-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.69']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.69-errors-abstract" />
      <sch:assert id="a-14437" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.69'])=1">SHALL contain exactly one [1..1] templateId (CONF:14436) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.69" (CONF:14437).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.69-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.69-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.69-errors-abstract" />
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.69-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.69']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.69-errors-abstract" />
      <sch:assert id="a-12497" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.69'])=1">SHALL contain exactly one [1..1] templateId (CONF:12496) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.69" (CONF:12497).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.79-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.79-errors-abstract" abstract="true">
      <sch:assert id="a-14851" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:14851).</sch:assert>
      <sch:assert id="a-14852" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:14852).</sch:assert>
      <sch:assert id="a-14853" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:14853).</sch:assert>
      <sch:assert id="a-14854" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:14854).</sch:assert>
      <sch:assert id="a-14855" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:14855).</sch:assert>
      <sch:assert id="a-14857" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:14857).</sch:assert>
      <sch:assert id="a-14873" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:14873).</sch:assert>
      <sch:assert id="a-14874" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:14874).</sch:assert>
      <sch:assert id="a-15142" test="cda:value[@code='419099009' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="419099009" Dead (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:15142).</sch:assert>
      <sch:assert id="a-19095" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19095).</sch:assert>
      <sch:assert id="a-19135" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:19135).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.79-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.79']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.79-errors-abstract" />
      <sch:assert id="a-14872" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.79'])=1">SHALL contain exactly one [1..1] templateId (CONF:14871) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.79" (CONF:14872).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.54-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.54-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.79-errors-abstract" />
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.54-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.54']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.54-errors-abstract" />
      <sch:assert id="a-12541" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.54'])=1">SHALL contain exactly one [1..1] templateId (CONF:12540) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.54" (CONF:12541).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.51-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.51-errors-abstract" abstract="true">
      <sch:assert id="a-12526" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" event, which SHALL be selected from CodeSystem ActMood (2.16.840.1.113883.5.1001) STATIC (CONF:12526).</sch:assert>
      <sch:assert id="a-12536" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12536).</sch:assert>
      <sch:assert id="a-13041" test="count(cda:code[@code='ASSERTION'][@codeSystem='2.16.840.1.113883.5.4'])=1">SHALL contain exactly one [1..1] code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:13041).</sch:assert>
      <sch:assert id="a-13042" test="count(cda:statusCode[@code='active'])=1">SHALL contain exactly one [1..1] statusCode="active" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13042).</sch:assert>
      <sch:assert id="a-16711" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:16711).</sch:assert>
      <sch:assert id="a-16712" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:16712).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.51-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.51']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.51-errors-abstract" />
      <sch:assert id="a-12538" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.51'])=1">SHALL contain exactly one [1..1] templateId (CONF:12537) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.51" (CONF:12538).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.55-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.55-errors-abstract" abstract="true">
      <sch:assert id="a-12564" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:12564).</sch:assert>
      <sch:assert id="a-12565" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12565).</sch:assert>
      <sch:assert id="a-14029" test="cda:code[@code='48768-6' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL contain exactly one [1..1] @code="48768-6" Payment source (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:14029).</sch:assert>
      <sch:assert id="a-14213" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:14213).</sch:assert>
      <sch:assert id="a-14214" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:14214).</sch:assert>
      <sch:assert id="a-16710" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:16710).</sch:assert>
      <sch:assert id="a-16855" test="cda:value[@code]">This value SHALL contain exactly one [1..1] @code (CONF:16855).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.55-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.55-errors-abstract" />
      <sch:assert id="a-12562" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.55'])=1">SHALL contain exactly one [1..1] templateId (CONF:12561) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.55" (CONF:12562).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.42-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.42-errors-abstract" abstract="true">
      <sch:assert id="a-8572" test="@classCode='SBADM'">SHALL contain exactly one [1..1] @classCode="SBADM" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8572).</sch:assert>
      <sch:assert id="a-8573" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.24.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.24']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet Plan of Care moodCode (SubstanceAdministration/Supply) 2.16.840.1.113883.11.20.9.24 STATIC 2011-09-30 (CONF:8573).</sch:assert>
      <sch:assert id="a-8575" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8575).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.42-errors" context="cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.42']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.42-errors-abstract" />
      <sch:assert id="a-10514" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.42'])=1">SHALL contain exactly one [1..1] templateId (CONF:8574) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.42" (CONF:10514).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.47-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.47-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.42-errors-abstract" />
      <sch:assert id="a-12592" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:12592).</sch:assert>
      <sch:assert id="a-12610" test="count(cda:consumable)=1">SHALL contain exactly one [1..1] consumable (CONF:12610).</sch:assert>
      <sch:assert id="a-12611" test="cda:consumable[count(cda:manufacturedProduct[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.23'])=1]">This consumable SHALL contain exactly one [1..1] Medication Information (templateId:2.16.840.1.113883.10.20.22.4.23) (CONF:12611).</sch:assert>
      <sch:assert id="a-12639" test="@moodCode='RQO'">SHALL contain exactly one [1..1] @moodCode="RQO" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12639).</sch:assert>
      <sch:assert id="a-12641" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12641).</sch:assert>
      <sch:assert id="a-13818" test="count(cda:effectiveTime[@xsi:type='IVL_TS'][@xsi:type='IVL_TS'][count(cda:high)=1][count(cda:low)=1])=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12593) such that it SHALL contain exactly one [1..1] low (CONF:13818).</sch:assert>
      <sch:assert id="a-13819" test="count(cda:effectiveTime[@xsi:type='IVL_TS'][@xsi:type='IVL_TS'][count(cda:low)=1][count(cda:high)=1])=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12593) such that it SHALL contain exactly one [1..1] high (CONF:13819).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.47-errors" context="cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.47']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.47-errors-abstract" />
      <sch:assert id="a-12586" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.47'])=1">SHALL contain exactly one [1..1] templateId (CONF:12585) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.47" (CONF:12586).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.13-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.13-errors-abstract" abstract="true">
      <sch:assert id="a-8237" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.18.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.18']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet MoodCodeEvnInt 2.16.840.1.113883.11.20.9.18 STATIC 2011-04-03 (CONF:8237).</sch:assert>
      <sch:assert id="a-8239" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8239).</sch:assert>
      <sch:assert id="a-8245" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode, which SHALL be selected from ValueSet ProcedureAct statusCode 2.16.840.1.113883.11.20.9.22 DYNAMIC (CONF:8245).</sch:assert>
      <sch:assert id="a-8282" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8282).</sch:assert>
      <sch:assert id="a-16846" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:16846).</sch:assert>
      <sch:assert id="a-19197" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:19197).</sch:assert>
      <sch:assert id="a-19201" test="count(cda:code/cda:originalText/cda:reference[@value])=0 or starts-with(cda:code/cda:originalText/cda:reference/@value, '#')">This reference/@value SHALL begin with a '#' and SHALL point to its corresponding narrative (using the approach defined in CDA Release 2, section 4.3.5.1) (CONF:19201).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.13-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.13']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.13-errors-abstract" />
      <sch:assert id="a-10520" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.13'])=1">SHALL contain exactly one [1..1] templateId (CONF:8238) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.13" (CONF:10520).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.59-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.59-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.13-errors-abstract" />
      <sch:assert id="a-12643" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12643).</sch:assert>
      <sch:assert id="a-12649" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:12649).</sch:assert>
      <sch:assert id="a-12650" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12650).</sch:assert>
      <sch:assert id="a-12651" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12651).</sch:assert>
      <sch:assert id="a-12652" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:12652).</sch:assert>
      <sch:assert id="a-12653" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:12653).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.59-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.59']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.59-errors-abstract" />
      <sch:assert id="a-12645" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.59'])=1">SHALL contain exactly one [1..1] templateId (CONF:12644) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.59" (CONF:12645).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.60-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.60-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" />
      <sch:assert id="a-12665" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12665).</sch:assert>
      <sch:assert id="a-12669" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12669).</sch:assert>
      <sch:assert id="a-12670" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:12670).</sch:assert>
      <sch:assert id="a-12671" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12671).</sch:assert>
      <sch:assert id="a-12682" test="count(cda:author)=1">SHALL contain exactly one [1..1] author (CONF:12682).</sch:assert>
      <sch:assert id="a-12683" test="cda:author[count(cda:time)=1]">This author SHALL contain exactly one [1..1] time (CONF:12683).</sch:assert>
      <sch:assert id="a-13274" test="cda:code[@code='5880005' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="5880005" physical examination (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:13274).</sch:assert>
      <sch:assert id="a-13275" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:13275).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.60-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.60']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.60-errors-abstract" />
      <sch:assert id="a-12667" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.60'])=1">SHALL contain exactly one [1..1] templateId (CONF:12666) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.60" (CONF:12667).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.58-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.58-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" />
      <sch:assert id="a-12685" test="@moodCode='RQO'">SHALL contain exactly one [1..1] @moodCode="RQO" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12685).</sch:assert>
      <sch:assert id="a-12689" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12689).</sch:assert>
      <sch:assert id="a-12690" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:12690).</sch:assert>
      <sch:assert id="a-12691" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12691).</sch:assert>
      <sch:assert id="a-12694" test="count(cda:author[count(cda:time)=1])=1">SHALL contain exactly one [1..1] author (CONF:12693) such that it SHALL contain exactly one [1..1] time (CONF:12694).</sch:assert>
      <sch:assert id="a-13242" test="cda:code[@code='5880005' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="5880005" physical examination (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:13242).</sch:assert>
      <sch:assert id="a-13254" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:13254).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.58-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.58']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.58-errors-abstract" />
      <sch:assert id="a-12687" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.58'])=1">SHALL contain exactly one [1..1] templateId (CONF:12686) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.58" (CONF:12687).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.57-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.57-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-errors-abstract" />
      <sch:assert id="a-16699" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:16699).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.57-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.57']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.57-errors-abstract" />
      <sch:assert id="a-12706" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.57'])=1">SHALL contain exactly one [1..1] templateId (CONF:12705) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.57" (CONF:12706).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.26-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.26-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.13-errors-abstract" />
      <sch:assert id="a-12752" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12752).</sch:assert>
      <sch:assert id="a-12757" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12757).</sch:assert>
      <sch:assert id="a-12758" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:12758).</sch:assert>
      <sch:assert id="a-12759" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12759).</sch:assert>
      <sch:assert id="a-12760" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12760).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.26-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.26']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.26-errors-abstract" />
      <sch:assert id="a-12754" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.26'])=1">SHALL contain exactly one [1..1] templateId (CONF:12753) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.26" (CONF:12754).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.25-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.25-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" />
      <sch:assert id="a-12774" test="@moodCode='RQO'">SHALL contain exactly one [1..1] @moodCode="RQO" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12774).</sch:assert>
      <sch:assert id="a-12778" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12778).</sch:assert>
      <sch:assert id="a-12779" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:12779).</sch:assert>
      <sch:assert id="a-12780" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12780).</sch:assert>
      <sch:assert id="a-12783" test="count(cda:author[count(cda:time)=1])=1">SHALL contain exactly one [1..1] author (CONF:12782) such that it SHALL contain exactly one [1..1] time (CONF:12783).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.25-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.25']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.25-errors-abstract" />
      <sch:assert id="a-12776" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.25'])=1">SHALL contain exactly one [1..1] templateId (CONF:12775) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.25" (CONF:12776).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.17.2.4-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.4-errors-abstract" abstract="true">
      <sch:assert id="a-3865" test="count(cda:code[@code='55188-7'][@codeSystem='2.16.840.1.113883.6.1'])">SHALL contain exactly one [1..1] code with @xsi:type="CS" (CONF:3865).</sch:assert>
      <sch:assert id="a-3866" test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='patient data'])=1">SHALL contain exactly one [1..1] title="Patient Data" (CONF:3866).</sch:assert>
      <sch:assert id="a-3867" test="count(cda:text)=1">SHALL contain exactly one [1..1] text (CONF:3867).</sch:assert>
      <sch:assert id="a-14567" test="count(cda:entry) &gt; 0">SHALL contain at least one [1..*] entry (CONF:14567).</sch:assert>
      <sch:assert id="a-19231" test="cda:code[@code='55188-7' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL contain exactly one [1..1] @code="55188-7" (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:19231).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.4-errors" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.4']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.2.4-errors-abstract" />
      <sch:assert id="a-12795" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.17.2.4'])=1">SHALL contain exactly one [1..1] templateId (CONF:12794) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.17.2.4" (CONF:12795).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.2.1-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.1-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.2.4-errors-abstract" />
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.1-errors" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.1-errors-abstract" />
      <sch:assert id="a-12797" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.2.1'])=1">SHALL contain exactly one [1..1] templateId (CONF:12796) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.2.1" (CONF:12797).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.2.2-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.2-errors-abstract" abstract="true">
      <sch:assert id="a-12798" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12798).</sch:assert>
      <sch:assert id="a-12799" test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='measure section'])=1">SHALL contain exactly one [1..1] title="Measure Section" (CONF:12799).</sch:assert>
      <sch:assert id="a-12800" test="count(cda:text)=1">SHALL contain exactly one [1..1] text (CONF:12800).</sch:assert>
      <sch:assert id="a-16677" test="count(cda:entry[count(cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98'])=1]) &gt; 0">SHALL contain at least one [1..*] entry (CONF:13003) such that it SHALL contain exactly one [1..1] Measure Reference (templateId:2.16.840.1.113883.10.20.24.3.98) (CONF:16677).</sch:assert>
      <sch:assert id="a-19230" test="cda:code[@code='55186-1' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL contain exactly one [1..1] @code="55186-1" Measure Section (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:19230).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.2-errors" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.2-errors-abstract" />
      <sch:assert id="a-12802" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.2.2'])=1">SHALL contain exactly one [1..1] templateId (CONF:12801) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.2.2" (CONF:12802).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.2.3-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.3-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.2-errors-abstract" />
      <sch:assert id="a-12978" test="count(cda:entry) &gt; 0">SHALL contain at least one [1..*] entry (CONF:12978).</sch:assert>
      <sch:assert id="a-13193" test="cda:entry[count(cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.97'])=1]">Such entries SHALL contain exactly one [1..1] eMeasure Reference QDM (templateId:2.16.840.1.113883.10.20.24.3.97) (CONF:13193).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.3-errors" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.3']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.3-errors-abstract" />
      <sch:assert id="a-12804" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.2.3'])=1">SHALL contain exactly one [1..1] templateId (CONF:12803) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.2.3" (CONF:12804).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.98-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.98-errors-abstract" abstract="true">
      <sch:assert id="a-12979" test="@classCode='CLUSTER'">SHALL contain exactly one [1..1] @classCode="CLUSTER" cluster (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12979).</sch:assert>
      <sch:assert id="a-12980" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12980).</sch:assert>
      <sch:assert id="a-12981" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12981).</sch:assert>
      <sch:assert id="a-12984" test="count(cda:reference[@typeCode='REFR'][count(cda:externalDocument[@classCode='DOC'])=1])=1">SHALL contain exactly one [1..1] reference (CONF:12982) such that it SHALL contain exactly one [1..1] @typeCode="REFR" refers to (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:12983). SHALL contain exactly one [1..1] externalDocument="DOC" Document (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12984).</sch:assert>
      <sch:assert id="a-12986" test="count(cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:id[@root]) &gt; 0]) &gt; 0">This externalDocument SHALL contain exactly one [1..1] id (CONF:12985) such that it SHALL contain exactly one [1..1] @root (CONF:12986).</sch:assert>
      <sch:assert id="a-12987" test="count(cda:reference/cda:externalDocument/cda:id) &gt; 0">This ID references the ID of the Quality Measure (CONF:12987).</sch:assert>
      <sch:assert id="a-12998" test="count(cda:reference/cda:externalDocument/cda:text) = 1">This text is the title of the eMeasure (CONF:12998).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.98-errors" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.98-errors-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.97-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.97-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.98-errors-abstract" />
      <sch:assert id="a-12805" test="@classCode='CLUSTER'">SHALL contain exactly one [1..1] @classCode="CLUSTER" cluster (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12805).</sch:assert>
      <sch:assert id="a-12806" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12806).</sch:assert>
      <sch:assert id="a-12807" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12807).</sch:assert>
      <sch:assert id="a-12810" test="count(cda:reference[@typeCode='REFR'][count(cda:externalDocument[@classCode='DOC'])=1])=1">SHALL contain exactly one [1..1] reference (CONF:12808) such that it SHALL contain exactly one [1..1] @typeCode="REFR" refers to (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:12809). SHALL contain exactly one [1..1] externalDocument="DOC" Document (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12810).</sch:assert>
      <sch:assert id="a-12812" test="count(cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:id[@root]) &gt; 0]) &gt; 0">This externalDocument SHALL contain exactly one [1..1] id (CONF:12811) such that it SHALL contain exactly one [1..1] @root (CONF:12812).</sch:assert>
      <sch:assert id="a-12813" test="count(cda:reference/cda:externalDocument/cda:id) &gt; 0">This ID SHALL equal the version specific identifier for eMeasure (i.e. QualityMeasureDocument/id) (CONF:12813).</sch:assert>
      <sch:assert id="a-12866" test="count(cda:reference/cda:externalDocument/cda:text) = 1">This text SHALL equal the title of the eMeasure (CONF:12866).</sch:assert>
      <sch:assert id="a-12868" test="count(cda:reference/cda:externalDocument/cda:setId) = 1">This setId SHALL equal the QualityMeasureDocument/setId which is the eMeasure version neutral id (CONF:12868).</sch:assert>
      <sch:assert id="a-12870" test="count(cda:reference/cda:externalDocument/cda:versionNumber) = 1">The version number SHALL equal the sequential eMeasure Version number (CONF:12870).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.97-errors" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.97']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.97-errors-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.27-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.27-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" />
      <sch:assert id="a-12814" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12814).</sch:assert>
      <sch:assert id="a-12818" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:12818).</sch:assert>
      <sch:assert id="a-12819" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:12819).</sch:assert>
      <sch:assert id="a-12820" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12820).</sch:assert>
      <sch:assert id="a-12823" test="count(cda:author[count(cda:time)=1])=1">SHALL contain exactly one [1..1] author (CONF:12822) such that it SHALL contain exactly one [1..1] time (CONF:12823).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.27-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.27']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.27-errors-abstract" />
      <sch:assert id="a-12816" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.25'])=1">SHALL contain exactly one [1..1] templateId (CONF:12815) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.25" (CONF:12816).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.67-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.67-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-errors-abstract" />
      <sch:assert id="a-13905" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:13905).</sch:assert>
      <sch:assert id="a-13906" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13906).</sch:assert>
      <sch:assert id="a-13907" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:13907).</sch:assert>
      <sch:assert id="a-13908" test="count(cda:code)=1">SHALL contain exactly one [1..1] code, where the @code SHOULD be selected from CodeSystem LOINC (2.16.840.1.113883.6.1) (CONF:13908).</sch:assert>
      <sch:assert id="a-13929" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:13929).</sch:assert>
      <sch:assert id="a-13930" test="count(cda:effectiveTime)=1">Represents clinically effective time of the measurement, which may be when the measurement was performed (e.g., a BP measurement), or may be when sample was taken (and measured some time afterwards) 
SHALL contain exactly one [1..1] effectiveTime (CONF:13930).</sch:assert>
      <sch:assert id="a-13932" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:13932).</sch:assert>
      <sch:assert id="a-19101" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19101).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.67-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.67']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.67-errors-abstract" />
      <sch:assert id="a-13890" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.67'])=1">SHALL contain exactly one [1..1] templateId (CONF:13889) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.67" (CONF:13890).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.28-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.28-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.67-errors-abstract" />
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.28-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.28']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.28-errors-abstract" />
      <sch:assert id="a-12836" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.28'])=1">SHALL contain exactly one [1..1] templateId (CONF:12835) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.28" (CONF:12836).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.77-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.77-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-errors-abstract" />
      <sch:assert id="a-12898" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:12898).</sch:assert>
      <sch:assert id="a-13132" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13132).</sch:assert>
      <sch:assert id="a-13133" test="cda:code[@code='418799008' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="418799008" symptom (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:13133).</sch:assert>
      <sch:assert id="a-13220" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:13220).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.77-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.77']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.77-errors-abstract" />
      <sch:assert id="a-12878" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.77'])=1">SHALL contain exactly one [1..1] templateId (CONF:12877) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.77" (CONF:12878).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.1.1-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.1.1-errors-abstract" abstract="true">
      <sch:assert id="a-5250" test="cda:typeId[@root='2.16.840.1.113883.1.3']">This typeId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.1.3" (CONF:5250).</sch:assert>
      <sch:assert id="a-5251" test="cda:typeId[@extension='POCD_HD000040']">This typeId SHALL contain exactly one [1..1] @extension="POCD_HD000040" (CONF:5251).</sch:assert>
      <sch:assert id="a-5253" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:5253).</sch:assert>
      <sch:assert id="a-5254" test="count(cda:title)=1">SHALL contain exactly one [1..1] title (CONF:5254).</sch:assert>
      <sch:assert id="a-5256" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:5256).</sch:assert>
      <sch:assert id="a-5259" test="count(cda:confidentialityCode[@code=document('2.16.840.1.113883.1.11.16926.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.1.11.16926']/svs:ConceptList/svs:Concept/@code])=1">SHALL contain exactly one [1..1] confidentialityCode, which SHOULD be selected from ValueSet HL7 BasicConfidentialityKind 2.16.840.1.113883.1.11.16926 STATIC 2010-04-21 (CONF:5259).</sch:assert>
      <sch:assert id="a-5266" test="count(cda:recordTarget) &gt; 0">SHALL contain at least one [1..*] recordTarget (CONF:5266).</sch:assert>
      <sch:assert id="a-5267" test="cda:recordTarget[count(cda:patientRole)=1]">Such recordTargets SHALL contain exactly one [1..1] patientRole (CONF:5267).</sch:assert>
      <sch:assert id="a-5268" test="cda:recordTarget/cda:patientRole[count(cda:id) &gt; 0]">This patientRole SHALL contain at least one [1..*] id (CONF:5268).</sch:assert>
      <sch:assert id="a-5271" test="cda:recordTarget/cda:patientRole[count(cda:addr) &gt; 0]">This patientRole SHALL contain at least one [1..*] addr (CONF:5271).</sch:assert>
      <sch:assert id="a-5280" test="cda:recordTarget/cda:patientRole[count(cda:telecom) &gt; 0]">This patientRole SHALL contain at least one [1..*] telecom (CONF:5280).</sch:assert>
      <sch:assert id="a-5283" test="cda:recordTarget/cda:patientRole[count(cda:patient)=1]">This patientRole SHALL contain exactly one [1..1] patient (CONF:5283).</sch:assert>
      <sch:assert id="a-5284" test="cda:recordTarget/cda:patientRole/cda:patient[count(cda:name)=1]">This patient SHALL contain exactly one [1..1] name (CONF:5284).</sch:assert>
      <sch:assert id="a-5298" test="cda:recordTarget/cda:patientRole/cda:patient[count(cda:birthTime)=1]">This patient SHALL contain exactly one [1..1] birthTime (CONF:5298).</sch:assert>
      <sch:assert id="a-5361" test="count(cda:typeId)=1">SHALL contain exactly one [1..1] typeId (CONF:5361).</sch:assert>
      <sch:assert id="a-5363" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:5363).</sch:assert>
      <sch:assert id="a-5372" test="count(cda:languageCode)=1">SHALL contain exactly one [1..1] languageCode, which SHALL be selected from ValueSet Language 2.16.840.1.113883.1.11.11526 DYNAMIC (CONF:5372).</sch:assert>
      <sch:assert id="a-5385" test="not(cda:recordTarget/cda:patientRole/cda:patient/cda:guardian) or cda:recordTarget/cda:patientRole/cda:patient/cda:guardian[count(cda:guardianPerson)=1]">The guardian, if present, SHALL contain exactly one [1..1] guardianPerson (CONF:5385).</sch:assert>
      <sch:assert id="a-5386" test="not(cda:recordTarget/cda:patientRole/cda:patient/cda:guardian/cda:guardianPerson) or cda:recordTarget/cda:patientRole/cda:patient/cda:guardian/cda:guardianPerson[count(cda:name) &gt; 0]">This guardianPerson SHALL contain at least one [1..*] name (CONF:5386).</sch:assert>
      <sch:assert id="a-5396" test="not(cda:recordTarget/cda:patientRole/cda:patient/cda:birthplace) or cda:recordTarget/cda:patientRole/cda:patient/cda:birthplace[count(cda:place)=1]">The birthplace, if present, SHALL contain exactly one [1..1] place (CONF:5396).</sch:assert>
      <sch:assert id="a-5397" test="not(cda:recordTarget/cda:patientRole/cda:patient/cda:birthplace/cda:place) or cda:recordTarget/cda:patientRole/cda:patient/cda:birthplace/cda:place[count(cda:addr)=1]">This place SHALL contain exactly one [1..1] addr (CONF:5397).</sch:assert>

      <sch:assert id="a-5402" test="not((cda:recordTarget/cda:patientRole/cda:patient/cda:birthplace/cda:place/cda:addr[cda:country='US' or cda:country='USA' or not(cda:country)]) and not(cda:recordTarget/cda:patientRole/cda:patient/cda:birthplace/cda:place/cda:addr/cda:state))">If country is US, this addr SHALL contain exactly one [1..1] state, which SHALL be selected from ValueSet 2.16.840.1.113883.3.88.12.80.1 StateValueSet DYNAMIC (CONF:5402).</sch:assert>

      <sch:assert id="a-7293" test="not((cda:recordTarget/cda:patientRole/cda:addr[(cda:country='US' or cda:country='USA' or not(cda:country)) and not(@nullFlavor)]) and not(cda:recordTarget/cda:patientRole/cda:addr/cda:state))">If country is US, this addr SHALL contain exactly one [1..1] state, which SHALL be selected from ValueSet 2.16.840.1.113883.3.88.12.80.1 StateValueSet DYNAMIC (CONF:7293).</sch:assert>

      <sch:assert id="a-5407" test="not(cda:recordTarget/cda:patientRole/cda:patient/cda:languageCommunication) or cda:recordTarget/cda:patientRole/cda:patient/cda:languageCommunication[count(cda:languageCode)=1]">The languageCommunication, if present, SHALL contain exactly one [1..1] languageCode, which SHALL be selected from ValueSet Language 2.16.840.1.113883.1.11.11526 DYNAMIC (CONF:5407).</sch:assert>
      <sch:assert id="a-5417" test="not(cda:recordTarget/cda:patientRole/cda:providerOrganization) or cda:recordTarget/cda:patientRole/cda:providerOrganization[count(cda:id) &gt; 0]">The providerOrganization, if present, SHALL contain at least one [1..*] id (CONF:5417).</sch:assert>
      <sch:assert id="a-5419" test="not(cda:recordTarget/cda:patientRole/cda:providerOrganization) or cda:recordTarget/cda:patientRole/cda:providerOrganization[count(cda:name) &gt; 0]">The providerOrganization, if present, SHALL contain at least one [1..*] name (CONF:5419).</sch:assert>
      <sch:assert id="a-5420" test="not(cda:recordTarget/cda:patientRole/cda:providerOrganization) or cda:recordTarget/cda:patientRole/cda:providerOrganization[count(cda:telecom) &gt; 0]">The providerOrganization, if present, SHALL contain at least one [1..*] telecom (CONF:5420).</sch:assert>
      <sch:assert id="a-5422" test="not(cda:recordTarget/cda:patientRole/cda:providerOrganization) or cda:recordTarget/cda:patientRole/cda:providerOrganization[count(cda:addr) &gt; 0]">The providerOrganization, if present, SHALL contain at least one [1..*] addr (CONF:5422).</sch:assert>
      <sch:assert id="a-5428" test="cda:author/cda:assignedAuthor[count(cda:telecom) &gt; 0]">This assignedAuthor SHALL contain at least one [1..*] telecom (CONF:5428).</sch:assert>
      <sch:assert id="a-5444" test="count(cda:author) &gt; 0">SHALL contain at least one [1..*] author (CONF:5444).</sch:assert>
      <sch:assert id="a-5445" test="cda:author[count(cda:time)=1]">Such authors SHALL contain exactly one [1..1] time (CONF:5445).</sch:assert>
      <sch:assert id="a-5448" test="cda:author[count(cda:assignedAuthor)=1]">Such authors SHALL contain exactly one [1..1] assignedAuthor (CONF:5448).</sch:assert>
      <sch:assert id="a-5452" test="cda:author/cda:assignedAuthor[count(cda:addr) &gt; 0]">This assignedAuthor SHALL contain at least one [1..*] addr (CONF:5452).</sch:assert>
      <sch:assert id="a-5519" test="count(cda:custodian)=1">SHALL contain exactly one [1..1] custodian (CONF:5519).</sch:assert>
      <sch:assert id="a-5520" test="cda:custodian[count(cda:assignedCustodian)=1]">This custodian SHALL contain exactly one [1..1] assignedCustodian (CONF:5520).</sch:assert>
      <sch:assert id="a-5521" test="cda:custodian/cda:assignedCustodian[count(cda:representedCustodianOrganization)=1]">This assignedCustodian SHALL contain exactly one [1..1] representedCustodianOrganization (CONF:5521).</sch:assert>
      <sch:assert id="a-5522" test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization[count(cda:id) &gt; 0]">This representedCustodianOrganization SHALL contain at least one [1..*] id (CONF:5522).</sch:assert>
      <sch:assert id="a-5524" test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization[count(cda:name)=1]">This representedCustodianOrganization SHALL contain exactly one [1..1] name (CONF:5524).</sch:assert>
      <sch:assert id="a-5525" test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization[count(cda:telecom)=1]">This representedCustodianOrganization SHALL contain exactly one [1..1] telecom (CONF:5525).</sch:assert>
      <sch:assert id="a-5559" test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization[count(cda:addr) &gt; 0]">This representedCustodianOrganization SHALL contain at least one [1..*] addr (CONF:5559).</sch:assert>
      <sch:assert id="a-6394" test="cda:recordTarget/cda:patientRole/cda:patient[count(cda:administrativeGenderCode)=1]">This patient SHALL contain exactly one [1..1] administrativeGenderCode, which SHALL be selected from ValueSet Administrative Gender (HL7 V3) 2.16.840.1.113883.1.11.1 DYNAMIC (CONF:6394).</sch:assert>
      <sch:assert id="a-16784" test="not(cda:author/cda:assignedAuthor/cda:assignedAuthoringDevice) or cda:author/cda:assignedAuthor/cda:assignedAuthoringDevice[count(cda:manufacturerModelName)=1]">The assignedAuthoringDevice, if present, SHALL contain exactly one [1..1] manufacturerModelName (CONF:16784).</sch:assert>
      <sch:assert id="a-16785" test="not(cda:author/cda:assignedAuthor/cda:assignedAuthoringDevice) or cda:author/cda:assignedAuthor/cda:assignedAuthoringDevice[count(cda:softwareName)=1]">The assignedAuthoringDevice, if present, SHALL contain exactly one [1..1] softwareName (CONF:16785).</sch:assert>
      <sch:assert id="a-16786" test="cda:author/cda:assignedAuthor[count(cda:id[@root='2.16.840.1.113883.4.6'])=1]">This assignedAuthor SHALL contain exactly one [1..1] id (CONF:5449) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.4.6" National Provider Identifier (CONF:16786).</sch:assert>
      <sch:assert id="a-16789" test="not(cda:author/cda:assignedAuthor/cda:assignedPerson) or cda:author/cda:assignedAuthor/cda:assignedPerson[count(cda:name) &gt; 0]">The assignedPerson, if present, SHALL contain at least one [1..*] name (CONF:16789).</sch:assert>
      <sch:assert id="a-16791" test="count(cda:realmCode[@code='US'])=1">SHALL contain exactly one [1..1] realmCode="US" (CONF:16791).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.1.1-errors" context="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.22.1.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.1.1-errors-abstract" />
      <sch:assert id="a-10036" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.1.1'])=1">SHALL contain exactly one [1..1] templateId (CONF:5252) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.1.1" (CONF:10036).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.1.1-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.1.1-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.1.1-errors-abstract" />
      <sch:assert id="a-12911" test="count(cda:code[@code='55182-0'][@codeSystem='2.16.840.1.113883.6.1'])=1">SHALL contain exactly one [1..1] code="55182-0" Quality Measure Report (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:12911).</sch:assert>
      <sch:assert id="a-12912" test="count(cda:title)=1">SHALL contain exactly one [1..1] title (CONF:12912).</sch:assert>
      <sch:assert id="a-12913" test="count(cda:recordTarget)=1">SHALL contain exactly one [1..1] recordTarget (CONF:12913).</sch:assert>
      <sch:assert id="a-12914" test="count(cda:custodian)=1">SHALL contain exactly one [1..1] custodian (CONF:12914).</sch:assert>
      <sch:assert id="a-12915" test="cda:custodian[count(cda:assignedCustodian)=1]">This custodian SHALL contain exactly one [1..1] assignedCustodian (CONF:12915).</sch:assert>
      <sch:assert id="a-12916" test="cda:custodian/cda:assignedCustodian[count(cda:representedCustodianOrganization)=1]">This assignedCustodian SHALL contain exactly one [1..1] representedCustodianOrganization (CONF:12916).</sch:assert>
      <sch:assert id="a-12917" test="count(cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization) = 1">This assignedCustodian SHALL represent the organization that owns and reports the data (CONF:12917).</sch:assert>
      <sch:assert id="a-12918" test="count(cda:component)=1">SHALL contain exactly one [1..1] component (CONF:12918).</sch:assert>
      <sch:assert id="a-12919" test="cda:component[count(cda:structuredBody)=1]">This component SHALL contain exactly one [1..1] structuredBody (CONF:12919).</sch:assert>
      <sch:assert id="a-13817" test="count(cda:legalAuthenticator)=1">SHALL contain exactly one [1..1] legalAuthenticator (CONF:13817).</sch:assert>
      <sch:assert id="a-17078" test="cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.2'])=1])=1]">This structuredBody SHALL contain exactly one [1..1] component (CONF:12920) such that it SHALL contain exactly one [1..1] Measure Section (templateId:2.16.840.1.113883.10.20.24.2.2) (CONF:17078).</sch:assert>
      <sch:assert id="a-17079" test="cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.1'])=1])=1]">This structuredBody SHALL contain exactly one [1..1] component (CONF:12923) such that it SHALL contain exactly one [1..1] Reporting Parameters Section (templateId:2.16.840.1.113883.10.20.17.2.1) (CONF:17079).</sch:assert>
      <sch:assert id="a-17080" test="cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.4'])=1])=1]">This structuredBody SHALL contain exactly one [1..1] component (CONF:12924) such that it SHALL contain exactly one [1..1] Patient Data Section (templateId:2.16.840.1.113883.10.20.17.2.4) (CONF:17080).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.1.1-errors" context="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.24.1.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.1.1-errors-abstract" />
      <sch:assert id="a-14613" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.1.1'])=1">SHALL contain exactly one [1..1] templateId (CONF:12910) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.1.1" (CONF:14613).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.18-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.18-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.13-errors-abstract" />
      <sch:assert id="a-12950" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:12950).</sch:assert>
      <sch:assert id="a-12956" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:12956).</sch:assert>
      <sch:assert id="a-12957" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:12957).</sch:assert>
      <sch:assert id="a-12958" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:12958).</sch:assert>
      <sch:assert id="a-12959" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:12959).</sch:assert>
      <sch:assert id="a-12960" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:12960).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.18-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.18']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.18-errors-abstract" />
      <sch:assert id="a-12952" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.18'])=1">SHALL contain exactly one [1..1] templateId (CONF:12951) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.18" (CONF:12952).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.1.2-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.1.2-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.1.1-errors-abstract" />
      <sch:assert id="a-16598" test="count(cda:recordTarget)=1">SHALL contain exactly one [1..1] recordTarget (CONF:16598).</sch:assert>
      <sch:assert id="a-16600" test="count(cda:custodian)=1">Where CMS requires submitter identification, the implementer should supply that information in the custodian/assignedCustodian/representedCustodianOrganization/id field.
SHALL contain exactly one [1..1] custodian (CONF:16600).</sch:assert>
      <sch:assert id="a-16856" test="cda:recordTarget[count(cda:patientRole)=1]">This recordTarget SHALL contain exactly one [1..1] patientRole (CONF:16856).</sch:assert>
      <sch:assert id="a-17081" test="count(cda:component[count(cda:structuredBody)=1])=1">SHALL contain exactly one [1..1] component (CONF:12973) such that it SHALL contain exactly one [1..1] structuredBody (CONF:17081).</sch:assert>
      <sch:assert id="a-17083" test="count(cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.3'])=1])=1])=1">This structuredBody SHALL contain exactly one [1..1] component (CONF:17082) such that it SHALL contain exactly one [1..1] Measure Section QDM (templateId:2.16.840.1.113883.10.20.24.2.3) (CONF:17083).</sch:assert>
      <sch:assert id="a-17092" test="count(cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.1'])=1])=1])=1">This structuredBody SHALL contain exactly one [1..1] component (CONF:17090) such that it SHALL contain exactly one [1..1] Reporting Parameters Section (templateId:2.16.840.1.113883.10.20.17.2.1) (CONF:17092).</sch:assert>
      <sch:assert id="a-17093" test="count(cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.1'])=1])=1])=1">This structuredBody SHALL contain exactly one [1..1] component (CONF:17091) such that it SHALL contain exactly one [1..1] Patient Data Section QDM (templateId:2.16.840.1.113883.10.20.24.2.1) (CONF:17093).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.1.2-errors" context="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.24.1.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.1.2-errors-abstract" />
      <sch:assert id="a-12972" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.1.2'])=1">SHALL contain exactly one [1..1] templateId="2.16.840.1.113883.10.20.24.1.2" (CONF:12972).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.81-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.81-errors-abstract" abstract="true">
      <sch:assert id="a-13185" test="count(cda:time)=1">SHALL contain exactly one [1..1] time (CONF:13185).</sch:assert>
      <sch:assert id="a-13186" test="count(cda:participantRole)=1">SHALL contain exactly one [1..1] participantRole (CONF:13186).</sch:assert>
      <sch:assert id="a-13187" test="cda:participantRole[@classCode='LOCE']">This participantRole SHALL contain exactly one [1..1] @classCode="LOCE" located entity (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:13187).</sch:assert>
      <sch:assert id="a-13188" test="@typeCode='ORG'">SHALL contain exactly one [1..1] @typeCode="ORG" origin (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:13188).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.81-errors" context="cda:Participant2[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.81']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.81-errors-abstract" />
      <sch:assert id="a-13190" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.81'])=1">SHALL contain exactly one [1..1] templateId (CONF:13189) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.81" (CONF:13190).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.100-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.100-errors-abstract" abstract="true">
      <sch:assert id="a-13371" test="count(cda:time)=1">SHALL contain exactly one [1..1] time (CONF:13371).</sch:assert>
      <sch:assert id="a-13372" test="count(cda:participantRole)=1">SHALL contain exactly one [1..1] participantRole (CONF:13372).</sch:assert>
      <sch:assert id="a-13373" test="cda:participantRole[@classCode='SDLOC']">This participantRole SHALL contain exactly one [1..1] @classCode="SDLOC" service delivery location (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:13373).</sch:assert>
      <sch:assert id="a-13374" test="@typeCode='LOC'">SHALL contain exactly one [1..1] @typeCode="LOC" location (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:13374).</sch:assert>
      <sch:assert id="a-13378" test="cda:participantRole[count(cda:code)=1]">This participantRole SHALL contain exactly one [1..1] code (CONF:13378).</sch:assert>
      <sch:assert id="a-13382" test="not(cda:participantRole/cda:playingEntity) or cda:participantRole/cda:playingEntity[@classCode='PLC']">The playingEntity, if present, SHALL contain exactly one [1..1] @classCode="PLC" place (CodeSystem: EntityClass 2.16.840.1.113883.5.41 STATIC) (CONF:13382).</sch:assert>
      <sch:assert id="a-13384" test="cda:time[count(cda:low)=1]">This time SHALL contain exactly one [1..1] low (CONF:13384).</sch:assert>
      <sch:assert id="a-13385" test="cda:time[count(cda:high)=1]">This time SHALL contain exactly one [1..1] high (CONF:13385).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.100-errors" context="cda:Participant2[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.100']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.100-errors-abstract" />
      <sch:assert id="a-13376" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.100'])=1">SHALL contain exactly one [1..1] templateId (CONF:13375) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.100" (CONF:13376).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.19-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.19-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" />
      <sch:assert id="a-13392" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13392).</sch:assert>
      <sch:assert id="a-13396" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13396).</sch:assert>
      <sch:assert id="a-13397" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:13397).</sch:assert>
      <sch:assert id="a-13398" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13398).</sch:assert>
      <sch:assert id="a-13401" test="count(cda:author[count(cda:time)=1])=1">SHALL contain exactly one [1..1] author (CONF:13400) such that it SHALL contain exactly one [1..1] time (CONF:13401).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.19-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.19']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.19-errors-abstract" />
      <sch:assert id="a-13394" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.19'])=1">SHALL contain exactly one [1..1] templateId (CONF:13393) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.19" (CONF:13394).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.17-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.17-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-errors-abstract" />
      <sch:assert id="a-13411" test="@moodCode='RQO'">SHALL contain exactly one [1..1] @moodCode="RQO" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13411).</sch:assert>
      <sch:assert id="a-13415" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13415).</sch:assert>
      <sch:assert id="a-13416" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:13416).</sch:assert>
      <sch:assert id="a-13417" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13417).</sch:assert>
      <sch:assert id="a-13420" test="count(cda:author[count(cda:time)=1])=1">SHALL contain exactly one [1..1] author (CONF:13419) such that it SHALL contain exactly one [1..1] time (CONF:13420).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.17-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.17']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.17-errors-abstract" />
      <sch:assert id="a-13413" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.17'])=1">SHALL contain exactly one [1..1] templateId (CONF:13412) such that it SHALL contain exactly one [1..1] templateId (CONF:13412) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.17 (CONF:13413).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.29-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.29-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-errors-abstract" />
      <sch:assert id="a-13538" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:13538).</sch:assert>
      <sch:assert id="a-13539" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13539).</sch:assert>
      <sch:assert id="a-13542" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:13542).</sch:assert>
      <sch:assert id="a-13543" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13543).</sch:assert>
      <sch:assert id="a-13544" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:13544).</sch:assert>
      <sch:assert id="a-13545" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13545).</sch:assert>
      <sch:assert id="a-13546" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:13546).</sch:assert>
      <sch:assert id="a-13547" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:13547).</sch:assert>
      <sch:assert id="a-13563" test="count(cda:entryRelationship[@typeCode='CAUS'][@inversionInd='true'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.32'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:13549) such that it SHALL contain exactly one [1..1] @typeCode="CAUS" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:13550). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:13551). SHALL contain exactly one [1..1] Intervention Performed (templateId:2.16.840.1.113883.10.20.24.3.32) (CONF:13563).</sch:assert>
      <sch:assert id="a-16412" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:16412).</sch:assert>
      <sch:assert id="a-16413" test="cda:value[@code='281647001' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="281647001" Adverse reaction (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16413).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.29-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.29']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.29-errors-abstract" />
      <sch:assert id="a-13541" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.29'])=1">SHALL contain exactly one [1..1] templateId (CONF:13540) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.29" (CONF:13541).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.12-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.12-errors-abstract" abstract="true">
      <sch:assert id="a-8289" test="@classCode='ACT'">SHALL contain exactly one [1..1] @classCode="ACT" Act (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8289).</sch:assert>
      <sch:assert id="a-8290" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.18.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.18']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet MoodCodeEvnInt 2.16.840.1.113883.11.20.9.18 STATIC 2011-04-03 (CONF:8290).</sch:assert>
      <sch:assert id="a-8292" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8292).</sch:assert>
      <sch:assert id="a-8293" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:8293).</sch:assert>
      <sch:assert id="a-8298" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode, which SHALL be selected from ValueSet ProcedureAct statusCode 2.16.840.1.113883.11.20.9.22 DYNAMIC (CONF:8298).</sch:assert>
      <sch:assert id="a-19189" test="count(cda:code/cda:originalText/cda:reference[@value])=0 or starts-with(cda:code/cda:originalText/cda:reference/@value, '#')">This reference/@value SHALL begin with a '#' and SHALL point to its corresponding narrative (using the approach defined in CDA Release 2, section 4.3.5.1) (CONF:19189).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.12-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.12']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.12-errors-abstract" />
      <sch:assert id="a-10519" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.12'])=1">SHALL contain exactly one [1..1] templateId (CONF:8291) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.12" (CONF:10519).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.32-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.32-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.12-errors-abstract" />
      <sch:assert id="a-13590" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13590).</sch:assert>
      <sch:assert id="a-13594" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13594).</sch:assert>
      <sch:assert id="a-13611" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:13611).</sch:assert>
      <sch:assert id="a-13612" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:13612).</sch:assert>
      <sch:assert id="a-13613" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:13613).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.32-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.32']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.32-errors-abstract" />
      <sch:assert id="a-13592" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.32'])=1">SHALL contain exactly one [1..1] templateId (CONF:13591) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.32" (CONF:13592).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.30-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.30-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-errors-abstract" />
      <sch:assert id="a-13657" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:13657).</sch:assert>
      <sch:assert id="a-13658" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13658).</sch:assert>
      <sch:assert id="a-13659" test="count(cda:templateId)=1">SHALL contain exactly one [1..1] templateId (CONF:13659).</sch:assert>
      <sch:assert id="a-13661" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:13661).</sch:assert>
      <sch:assert id="a-13662" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13662).</sch:assert>
      <sch:assert id="a-13663" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:13663).</sch:assert>
      <sch:assert id="a-13664" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:13664).</sch:assert>
      <sch:assert id="a-13665" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13665).</sch:assert>
      <sch:assert id="a-13666" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:13666).</sch:assert>
      <sch:assert id="a-13667" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:13667).</sch:assert>
      <sch:assert id="a-13683" test="count(cda:entryRelationship[@typeCode='CAUS'][@inversionInd='true'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.32'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:13679) such that it SHALL contain exactly one [1..1] @typeCode="CAUS" (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:13680). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:13681). SHALL contain exactly one [1..1] Intervention Performed (templateId:2.16.840.1.113883.10.20.24.3.32) (CONF:13683).</sch:assert>
      <sch:assert id="a-16414" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:16414).</sch:assert>
      <sch:assert id="a-16415" test="cda:value[@code='102460003' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="102460003" Decreased tolerance (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16415).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.30-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.30']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.30-errors-abstract" />
      <sch:assert id="a-13660" test="cda:templateId[@root='2.16.840.1.113883.10.20.24.3.30']">This templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.30" (CONF:13660).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.34-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.34-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.12-errors-abstract" />
      <sch:assert id="a-13713" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13713).</sch:assert>
      <sch:assert id="a-13714" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:13714).</sch:assert>
      <sch:assert id="a-13715" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:13715).</sch:assert>
      <sch:assert id="a-13716" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:13716).</sch:assert>
      <sch:assert id="a-13717" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13717).</sch:assert>
      <sch:assert id="a-13720" test="count(cda:entryRelationship[@typeCode='REFR'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.87'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:13718) such that it SHALL contain exactly one [1..1] @typeCode="REFR" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:13719). SHALL contain exactly one [1..1] Result (templateId:2.16.840.1.113883.10.20.24.3.87) (CONF:13720).</sch:assert>
      <sch:assert id="a-13721" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:13721).</sch:assert>
      <sch:assert id="a-13722" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13722).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.39-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.39-errors-abstract" abstract="true">
      <sch:assert id="a-8538" test="@classCode='ACT'">SHALL contain exactly one [1..1] @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8538).</sch:assert>
      <sch:assert id="a-8539" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.23.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.23']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet Plan of Care moodCode (Act/Encounter/Procedure) 2.16.840.1.113883.11.20.9.23 STATIC 2011-09-30 (CONF:8539).</sch:assert>
      <sch:assert id="a-8546" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8546).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.39-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.39']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.39-errors-abstract" />
      <sch:assert id="a-10510" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.39'])=1">SHALL contain exactly one [1..1] templateId (CONF:8544) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.39" (CONF:10510).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.31-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.31-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.39-errors-abstract" />
      <sch:assert id="a-13742" test="@moodCode='RQO'">SHALL contain exactly one [1..1] @moodCode="RQO" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13742).</sch:assert>
      <sch:assert id="a-13746" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13746).</sch:assert>
      <sch:assert id="a-13747" test="count(cda:author)=1">SHALL contain exactly one [1..1] author (CONF:13747).</sch:assert>
      <sch:assert id="a-13748" test="cda:author[count(cda:time)=1]">This author SHALL contain exactly one [1..1] time (CONF:13748).</sch:assert>
      <sch:assert id="a-13762" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:13762).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.31-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.31']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.31-errors-abstract" />
      <sch:assert id="a-13744" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.31'])=1">SHALL contain exactly one [1..1] templateId (CONF:13743) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.31" (CONF:13744).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.75-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.75-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.42-errors-abstract" />
      <sch:assert id="a-13784" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" intent (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13784).</sch:assert>
      <sch:assert id="a-13788" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:13788).</sch:assert>
      <sch:assert id="a-13789" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13789).</sch:assert>
      <sch:assert id="a-13791" test="count(cda:consumable)=1">SHALL contain exactly one [1..1] consumable (CONF:13791).</sch:assert>
      <sch:assert id="a-13792" test="cda:consumable[count(cda:manufacturedProduct)=1]">This consumable SHALL contain exactly one [1..1] manufacturedProduct (CONF:13792).</sch:assert>
      <sch:assert id="a-13793" test="cda:consumable/cda:manufacturedProduct[count(cda:manufacturedMaterial)=1]">This manufacturedProduct SHALL contain exactly one [1..1] manufacturedMaterial (CONF:13793).</sch:assert>
      <sch:assert id="a-13794" test="cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial[count(cda:code)=1]">This manufacturedMaterial SHALL contain exactly one [1..1] code (CONF:13794).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.75-errors" context="cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.75']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.75-errors-abstract" />
      <sch:assert id="a-13786" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.75'])=1">SHALL contain exactly one [1..1] templateId (CONF:13785) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.75" (CONF:13786).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.33-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.33-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.39-errors-abstract" />
      <sch:assert id="a-13763" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13763).</sch:assert>
      <sch:assert id="a-13767" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13767).</sch:assert>
      <sch:assert id="a-13768" test="count(cda:author)=1">SHALL contain exactly one [1..1] author (CONF:13768).</sch:assert>
      <sch:assert id="a-13769" test="cda:author[count(cda:time)=1]">This author SHALL contain exactly one [1..1] time (CONF:13769).</sch:assert>
      <sch:assert id="a-13783" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:13783).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.33-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.33']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.33-errors-abstract" />
      <sch:assert id="a-13765" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.33'])=1">SHALL contain exactly one [1..1] templateId (CONF:13764) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.63" (CONF:13765).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.20-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.20-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-errors-abstract" />
      <sch:assert id="a-16695" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:16695).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.20-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.20']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.20-errors-abstract" />
      <sch:assert id="a-13796" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.20'])=1">SHALL contain exactly one [1..1] templateId (CONF:13795) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.20" (CONF:13796).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.99-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.99-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.43-errors-abstract" />
      <sch:assert id="a-13820" test="@moodCode='RQO'">SHALL contain exactly one [1..1] @moodCode="RQO" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13820).</sch:assert>
      <sch:assert id="a-13826" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:13826).</sch:assert>
      <sch:assert id="a-13827" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:13827).</sch:assert>
      <sch:assert id="a-13828" test="cda:statusCode[@code='new']">This statusCode SHALL contain exactly one [1..1] @code="new" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13828).</sch:assert>
      <sch:assert id="a-13829" test="count(cda:effectiveTime[@xsi:type='IVL_TS'])=1">SHALL contain exactly one [1..1] effectiveTime (CONF:13829).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.99-errors" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.99']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.99-errors-abstract" />
      <sch:assert id="a-13822" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.99'])=1">SHALL contain exactly one [1..1] templateId (CONF:13821) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.99" (CONF:13822).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.18-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.18-errors-abstract" abstract="true">
      <sch:assert id="a-7451" test="@classCode='SPLY'">SHALL contain exactly one [1..1] @classCode="SPLY" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7451).</sch:assert>
      <sch:assert id="a-7452" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7452).</sch:assert>
      <sch:assert id="a-7454" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:7454).</sch:assert>
      <sch:assert id="a-7455" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode, which SHALL be selected from ValueSet Medication Fill Status 2.16.840.1.113883.3.88.12.80.64 DYNAMIC (CONF:7455).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.18-errors" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.18']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.18-errors-abstract" />
      <sch:assert id="a-10505" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.18'])=1">SHALL contain exactly one [1..1] templateId (CONF:7453) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.18" (CONF:10505).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.45-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.45-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.18-errors-abstract" />
      <sch:assert id="a-13854" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] code (CONF:13854).</sch:assert>
      <sch:assert id="a-13855" test="cda:statusCode[@code='completed']">This code SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13855).</sch:assert>
      <sch:assert id="a-13856" test="count(cda:effectiveTime[@xsi:type='IVL_TS'])=1">SHALL contain exactly one [1..1] effectiveTime (CONF:13856).</sch:assert>
      <sch:assert id="a-13857" test="cda:effectiveTime[@xsi:type='IVL_TS'][count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:13857).</sch:assert>
      <sch:assert id="a-13858" test="cda:effectiveTime[@xsi:type='IVL_TS'][count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:13858).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.45-errors" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.45']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.45-errors-abstract" />
      <sch:assert id="a-13852" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.45'])=1">SHALL contain exactly one [1..1] templateId (CONF:13851) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.45" (CONF:13852).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.36-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.36-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-errors-abstract" />
      <sch:assert id="a-13961" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:13961).</sch:assert>
      <sch:assert id="a-13962" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:13962).</sch:assert>
      <sch:assert id="a-13963" test="count(cda:templateId)=1">SHALL contain exactly one [1..1] templateId (CONF:13963).</sch:assert>
      <sch:assert id="a-13965" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:13965).</sch:assert>
      <sch:assert id="a-13966" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:13966).</sch:assert>
      <sch:assert id="a-13967" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:13967).</sch:assert>
      <sch:assert id="a-13968" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:13968).</sch:assert>
      <sch:assert id="a-13969" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:13969).</sch:assert>
      <sch:assert id="a-13970" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:13970).</sch:assert>
      <sch:assert id="a-13971" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:13971).</sch:assert>
      <sch:assert id="a-13976" test="count(cda:entryRelationship[@typeCode='CAUS'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.38'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:13973) such that it SHALL contain exactly one [1..1] @typeCode="CAUS" (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:13974). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:13975). SHALL contain exactly one [1..1] Laboratory Test Performed (templateId:2.16.840.1.113883.10.20.24.3.38) (CONF:13976).</sch:assert>
      <sch:assert id="a-14573" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:14573).</sch:assert>
      <sch:assert id="a-16418" test="cda:value[@code='102460003' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="102460003" Decreased tolerance (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16418).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.36-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.36']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.36-errors-abstract" />
      <sch:assert id="a-13964" test="cda:templateId[@root='2.16.840.1.113883.10.20.24.3.16']">This templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.16" (CONF:13964).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.35-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.35-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-errors-abstract" />
      <sch:assert id="a-14060" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:14060).</sch:assert>
      <sch:assert id="a-14061" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:14061).</sch:assert>
      <sch:assert id="a-14062" test="count(cda:templateId)=1">SHALL contain exactly one [1..1] templateId (CONF:14062).</sch:assert>
      <sch:assert id="a-14064" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:14064).</sch:assert>
      <sch:assert id="a-14065" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:14065).</sch:assert>
      <sch:assert id="a-14066" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:14066).</sch:assert>
      <sch:assert id="a-14067" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:14067).</sch:assert>
      <sch:assert id="a-14068" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:14068).</sch:assert>
      <sch:assert id="a-14069" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:14069).</sch:assert>
      <sch:assert id="a-14070" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:14070).</sch:assert>
      <sch:assert id="a-14075" test="count(cda:entryRelationship[@typeCode='CAUS'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.38'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:14072) such that it SHALL contain exactly one [1..1] @typeCode="CAUS" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:14073). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:14074). SHALL contain exactly one [1..1] Laboratory Test Performed (templateId:2.16.840.1.113883.10.20.24.3.38) (CONF:14075).</sch:assert>
      <sch:assert id="a-16416" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:16416).</sch:assert>
      <sch:assert id="a-16417" test="cda:value[@code='281647001' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="281647001" Adverse reaction (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16417).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.35-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.35']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.35-errors-abstract" />
      <sch:assert id="a-14063" test="cda:templateId[@root='2.16.840.1.113883.10.20.24.3.15']">This templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.15" (CONF:14063).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.7-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.7-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.90-errors-abstract" />
      <sch:assert id="a-7379" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7379).</sch:assert>
      <sch:assert id="a-7380" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7380).</sch:assert>
      <sch:assert id="a-7382" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:7382).</sch:assert>
      <sch:assert id="a-7387" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:7387).</sch:assert>
      <sch:assert id="a-7390" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:7390).</sch:assert>
      <sch:assert id="a-9139" test="cda:value[@code]">This value SHALL contain exactly one [1..1] @code, which SHALL be selected from ValueSet Allergy/Adverse Event Type 2.16.840.1.113883.3.88.12.3221.6.2 DYNAMIC (CONF:9139).</sch:assert>
      <sch:assert id="a-15947" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:15947).</sch:assert>
      <sch:assert id="a-15948" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:15948).</sch:assert>
      <sch:assert id="a-19084" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:19084).</sch:assert>
      <sch:assert id="a-19085" test="cda:statusCode/@code='completed'">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19085).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.7-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.7']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.7-errors-abstract" />
      <sch:assert id="a-10488" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.7'])=1">SHALL contain exactly one [1..1] templateId (CONF:7381) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.7" (CONF:10488).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.46-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.46-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.7-errors-abstract" />
      <sch:assert id="a-14086" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:14086).</sch:assert>
      <sch:assert id="a-14087" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:14087).</sch:assert>
      <sch:assert id="a-14090" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:14090).</sch:assert>
      <sch:assert id="a-14091" test="(.)">This code SHALL contain exactly one [1..1] @code="ASSERTION" (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:14091).</sch:assert>
      <sch:assert id="a-14092" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:14092).</sch:assert>
      <sch:assert id="a-14094" test="count(cda:participant)=1">SHALL contain exactly one [1..1] participant (CONF:14094).</sch:assert>
      <sch:assert id="a-14095" test="cda:participant[@typeCode='CSM']">This participant SHALL contain exactly one [1..1] @typeCode="CSM" (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:14095).</sch:assert>
      <sch:assert id="a-14096" test="cda:participant[count(cda:participantRole)=1]">This participant SHALL contain exactly one [1..1] participantRole (CONF:14096).</sch:assert>
      <sch:assert id="a-14097" test="cda:participant/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:14097).</sch:assert>
      <sch:assert id="a-14098" test="cda:participant/cda:participantRole[count(cda:playingEntity)=1]">This participantRole SHALL contain exactly one [1..1] playingEntity (CONF:14098).</sch:assert>
      <sch:assert id="a-14099" test="cda:participant/cda:participantRole/cda:playingEntity[count(cda:code)=1]">This playingEntity SHALL contain exactly one [1..1] code (CONF:14099).</sch:assert>
      <sch:assert id="a-14162" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:14162).</sch:assert>
      <sch:assert id="a-14163" test="cda:value[@code='59037007' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="59037007" Drug intolerance (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:14163).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.46-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.46']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.46-errors-abstract" />
      <sch:assert id="a-14089" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.46'])=1">SHALL contain exactly one [1..1] templateId (CONF:14088) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.46" (CONF:14089).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.43-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.43-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.7-errors-abstract" />
      <sch:assert id="a-14110" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:14110).</sch:assert>
      <sch:assert id="a-14111" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:14111).</sch:assert>
      <sch:assert id="a-14114" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:14114).</sch:assert>
      <sch:assert id="a-14115" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:14115).</sch:assert>
      <sch:assert id="a-14116" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:14116).</sch:assert>
      <sch:assert id="a-14118" test="count(cda:participant)=1">SHALL contain exactly one [1..1] participant (CONF:14118).</sch:assert>
      <sch:assert id="a-14119" test="cda:participant[@typeCode='CSM']">This participant SHALL contain exactly one [1..1] @typeCode="CSM" (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:14119).</sch:assert>
      <sch:assert id="a-14120" test="cda:participant[count(cda:participantRole)=1]">This participant SHALL contain exactly one [1..1] participantRole (CONF:14120).</sch:assert>
      <sch:assert id="a-14121" test="cda:participant/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:14121).</sch:assert>
      <sch:assert id="a-14122" test="cda:participant/cda:participantRole[count(cda:playingEntity)=1]">This participantRole SHALL contain exactly one [1..1] playingEntity (CONF:14122).</sch:assert>
      <sch:assert id="a-14123" test="cda:participant/cda:participantRole/cda:playingEntity[count(cda:code)=1]">This playingEntity SHALL contain exactly one [1..1] code (CONF:14123).</sch:assert>
      <sch:assert id="a-14134" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:14134).</sch:assert>
      <sch:assert id="a-14135" test="cda:value[@code='62014003' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="62014003" Adverse drug effect (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:14135).</sch:assert>
      <sch:assert id="a-14161" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:14161).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.43-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.43']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.43-errors-abstract" />
      <sch:assert id="a-14113" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.43'])=1">SHALL contain exactly one [1..1] templateId (CONF:14112) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.43" (CONF:14113).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.44-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.44-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.7-errors-abstract" />
      <sch:assert id="a-14136" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:14136).</sch:assert>
      <sch:assert id="a-14137" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:14137).</sch:assert>
      <sch:assert id="a-14140" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:14140).</sch:assert>
      <sch:assert id="a-14141" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:14141).</sch:assert>
      <sch:assert id="a-14142" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:14142).</sch:assert>
      <sch:assert id="a-14143" test="count(cda:participant)=1">SHALL contain exactly one [1..1] participant (CONF:14143).</sch:assert>
      <sch:assert id="a-14144" test="cda:participant[@typeCode='CSM']">This participant SHALL contain exactly one [1..1] @typeCode="CSM" (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:14144).</sch:assert>
      <sch:assert id="a-14145" test="cda:participant[count(cda:participantRole)=1]">This participant SHALL contain exactly one [1..1] participantRole (CONF:14145).</sch:assert>
      <sch:assert id="a-14146" test="cda:participant/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:14146).</sch:assert>
      <sch:assert id="a-14147" test="cda:participant/cda:participantRole[count(cda:playingEntity)=1]">This participantRole SHALL contain exactly one [1..1] playingEntity (CONF:14147).</sch:assert>
      <sch:assert id="a-14148" test="cda:participant/cda:participantRole/cda:playingEntity[count(cda:code)=1]">This playingEntity SHALL contain exactly one [1..1] code (CONF:14148).</sch:assert>
      <sch:assert id="a-14159" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:14159).</sch:assert>
      <sch:assert id="a-14160" test="cda:value[@code='416098002' and @codeSystem='2.16.840.1.113883.6.96']">This value SHALL contain exactly one [1..1] @code="416098002" Drug allergy (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:14160).</sch:assert>
      <sch:assert id="a-14164" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:14164).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.44-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.44']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.44-errors-abstract" />
      <sch:assert id="a-14139" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.44'])=1">SHALL contain exactly one [1..1] templateId (CONF:14138) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.44" (CONF:14139).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.45-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.45-errors-abstract" abstract="true">
      <sch:assert id="a-8600" test="@classCode='CLUSTER'">SHALL contain exactly one [1..1] @classCode="CLUSTER" Cluster (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8600).</sch:assert>
      <sch:assert id="a-8601" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:8601).</sch:assert>
      <sch:assert id="a-8602" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:8602).</sch:assert>
      <sch:assert id="a-8607" test="count(cda:component) &gt; 0">SHALL contain at least one [1..*] component (CONF:8607).</sch:assert>
      <sch:assert id="a-8609" test="count(cda:subject)=1">SHALL contain exactly one [1..1] subject (CONF:8609).</sch:assert>
      <sch:assert id="a-8610" test="cda:subject/cda:relatedSubject[@classCode='PRS']">This subject SHALL contain exactly one [1..1] relatedSubject/@classCode="PRS" Person (CodeSystem: EntityClass 2.16.840.1.113883.5.41 STATIC) (CONF:8610).</sch:assert>
      <sch:assert id="a-8611" test="cda:subject/cda:relatedSubject[@classCode='PRS'][count(cda:code)=1]">This relatedSubject SHALL contain exactly one [1..1] code (CONF:8611) (CONF:8611).</sch:assert>
      <sch:assert id="a-8614" test="not(cda:subject/cda:relatedSubject/cda:subject) or cda:subject/cda:relatedSubject/cda:subject[count(cda:administrativeGenderCode)=1]">The subject, if present, SHALL contain exactly one [1..1] administrativeGenderCode, where the @code SHALL be selected from ValueSet Administrative Gender (HL7 V3) 2.16.840.1.113883.1.11.1 DYNAMIC (CONF:8614).</sch:assert>
      <sch:assert id="a-15244" test="cda:subject[count(cda:relatedSubject)=1]">This subject SHALL contain exactly one [1..1] relatedSubject (CONF:15244).</sch:assert>
      <sch:assert id="a-15245" test="cda:subject/cda:relatedSubject[@classCode]">This relatedSubject SHALL contain exactly one [1..1] @classCode (CodeSystem: EntityClass 2.16.840.1.113883.5.41 STATIC) (CONF:15245).</sch:assert>
      <sch:assert id="a-15246" test="cda:subject/cda:relatedSubject[count(cda:code)=1]">This relatedSubject SHALL contain exactly one [1..1] code (CONF:15246).</sch:assert>
      <sch:assert id="a-15247" test="cda:subject/cda:relatedSubject/cda:code[not(@code) or @code]">This code SHALL contain zero or one [0..1] @code, which SHOULD be selected from ValueSet FamilyHistoryRelatedSubjectCode 2.16.840.1.113883.1.11.19579 DYNAMIC (CONF:15247).</sch:assert>
      <sch:assert id="a-15974" test="not(cda:subject/cda:relatedSubject/cda:subject) or cda:subject/cda:relatedSubject/cda:subject[count(cda:administrativeGenderCode)=1]">The subject, if present, SHALL contain exactly one [1..1] administrativeGenderCode (CONF:15974).</sch:assert>
      <sch:assert id="a-15975" test="not(cda:subject/cda:relatedSubject/cda:subject/cda:administrativeGenderCode) or cda:subject/cda:relatedSubject/cda:subject/cda:administrativeGenderCode[@code and @code=document('2.16.840.1.113883.1.11.1.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.1.11.1']/svs:ConceptList/svs:Concept/@code]">This administrativeGenderCode SHALL contain exactly one [1..1] @code, which SHALL be selected from ValueSet Administrative Gender (HL7 V3) 2.16.840.1.113883.1.11.1 STATIC (CONF:15975).</sch:assert>
      <sch:assert id="a-16888" test="cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.46'])=1]">Such components SHALL contain exactly one [1..1] Family History Observation (templateId:2.16.840.1.113883.10.20.22.4.46) (CONF:16888).</sch:assert>
      <sch:assert id="a-19099" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19099).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.45-errors" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.45']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.45-errors-abstract" />
      <sch:assert id="a-10497" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.45'])=1">SHALL contain exactly one [1..1] templateId (CONF:8604) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.45" (CONF:10497).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.12-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.12-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.45-errors-abstract" />
      <sch:assert id="a-14178" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:14178).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.12-errors" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.12']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.12-errors-abstract" />
      <sch:assert id="a-14176" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.12'])=1">SHALL contain exactly one [1..1] templateId (CONF:14175) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.12" (CONF:14176).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.102-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.102-errors-abstract" abstract="true">
      <sch:assert id="a-16425" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:16425).</sch:assert>
      <sch:assert id="a-16426" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:16426).</sch:assert>
      <sch:assert id="a-16427" test="count(cda:code[@code='20120615'][@codeSystem='2.16.840.1.113883.6.96'])=1">SHALL contain exactly one [1..1] code="20120615" Estimated Date of Conception (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16427).</sch:assert>
      <sch:assert id="a-16428" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:16428).</sch:assert>
      <sch:assert id="a-16429" test="count(cda:value[@xsi:type='TS'])=1">SHALL contain exactly one [1..1] value with @xsi:type="TS" (CONF:16429).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.102-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.102']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.102-errors-abstract" />
      <sch:assert id="a-16509" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.102'])=1">SHALL contain exactly one [1..1] templateId (CONF:16508) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.102" (CONF:16509).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.101-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.101-errors-abstract" abstract="true">
      <sch:assert id="a-16523" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CONF:16523).</sch:assert>
      <sch:assert id="a-16524" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" event (CONF:16524).</sch:assert>
      <sch:assert id="a-16527" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:16527).</sch:assert>
      <sch:assert id="a-16528" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:16528).</sch:assert>
      <sch:assert id="a-16529" test="cda:code[@code='57036006' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="57036006" Length of gestation  (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16529).</sch:assert>
      <sch:assert id="a-16530" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" Completed (CONF:16530).</sch:assert>
      <sch:assert id="a-16531" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:16531).</sch:assert>
      <sch:assert id="a-16532" test="count(cda:value[@xsi:type='PQ'])=1">SHALL contain exactly one [1..1] value with @xsi:type="PQ" (CONF:16532).</sch:assert>
      <sch:assert id="a-16534" test=".">This value SHALL contain exactly one [1..1] @unit="1", which SHALL be selected from ValueSet DayWkPQ_UCUM 2.16.840.1.113883.11.20.9.40 DYNAMIC (CONF:16534).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.101-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.101']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.101-errors-abstract" />
      <sch:assert id="a-16526" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.101'])=1">SHALL contain exactly one [1..1] templateId (CONF:16525) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.24.3.101" (CONF:16526).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.103-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.103-errors-abstract" abstract="true">
      <sch:assert id="a-16536" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CONF:16536).</sch:assert>
      <sch:assert id="a-16537" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:16537).</sch:assert>
      <sch:assert id="a-16538" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:16538).</sch:assert>
      <sch:assert id="a-16539" test="count(cda:statusCode[@code='completed'])=1">SHALL contain exactly one [1..1] statusCode="completed" Completed (CONF:16539).</sch:assert>
      <sch:assert id="a-16540" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:16540).</sch:assert>
      <sch:assert id="a-16541" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:16541).</sch:assert>
      <sch:assert id="a-16544" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:16544).</sch:assert>
      <sch:assert id="a-16545" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:16545).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.103-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.103']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.103-errors-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.105-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.105-errors-abstract" abstract="true">
      <sch:assert id="a-16550" test="@classCode='ACT'">SHALL contain exactly one [1..1] @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:16550).</sch:assert>
      <sch:assert id="a-16551" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:16551).</sch:assert>
      <sch:assert id="a-16552" test="count(cda:code[@code='10183-2'][@codeSystem='2.16.840.1.113883.6.1'][@xsi:type='CE'])=1">SHALL contain exactly one [1..1] code="10183-2" Discharge medication with @xsi:type="CE" (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:16552).</sch:assert>
      <sch:assert id="a-16555" test="count(cda:entryRelationship[@typeCode='SUBJ'][count(cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.41'])=1])=1">SHALL contain exactly one [1..1] entryRelationship (CONF:16553) such that it SHALL contain exactly one [1..1] @typeCode="SUBJ" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:16554). SHALL contain exactly one [1..1] Medication Active (templateId:2.16.840.1.113883.10.20.24.3.41) (CONF:16555).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.105-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.105']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.105-errors-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.25-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.25-errors-abstract" abstract="true" />
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.25-errors" context="cda:criterion[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.25']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.25-errors-abstract" />
      <sch:assert id="a-10517" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.25'])=1">SHALL contain exactly one [1..1] templateId (CONF:7372) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.25" (CONF:10517).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.20-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.20-errors-abstract" abstract="true">
      <sch:assert id="a-7391" test="@classCode='ACT'">SHALL contain exactly one [1..1] @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7391).</sch:assert>
      <sch:assert id="a-7392" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7392).</sch:assert>
      <sch:assert id="a-7396" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:7396).</sch:assert>
      <sch:assert id="a-16884" test="count(cda:code)=1">SHALL contain exactly one [1..1] code, which SHOULD be selected from ValueSet Patient Education 2.16.840.1.113883.11.20.9.34 DYNAMIC (CONF:16884).</sch:assert>
      <sch:assert id="a-19106" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19106).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.20-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.20']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.20-errors-abstract" />
      <sch:assert id="a-10503" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.20'])=1">SHALL contain exactly one [1..1] templateId (CONF:7393) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.20" (CONF:10503).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.23-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.23-errors-abstract" abstract="true">
      <sch:assert id="a-7408" test="@classCode='MANU'">SHALL contain exactly one [1..1] @classCode="MANU" (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:7408).</sch:assert>
      <sch:assert id="a-7411" test="count(cda:manufacturedMaterial)=1">SHALL contain exactly one [1..1] manufacturedMaterial (CONF:7411).</sch:assert>
      <sch:assert id="a-7412" test="cda:manufacturedMaterial[count(cda:code)=1]">This manufacturedMaterial SHALL contain exactly one [1..1] code, which SHALL be selected from ValueSet Medication Clinical Drug 2.16.840.1.113883.3.88.12.80.17 DYNAMIC (CONF:7412).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.23-errors" context="cda:manufacturedProduct[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.23']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.23-errors-abstract" />
      <sch:assert id="a-10506" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.23'])=1">SHALL contain exactly one [1..1] templateId (CONF:7409) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.23" (CONF:10506).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.17-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.17-errors-abstract" abstract="true">
      <sch:assert id="a-7427" test="@classCode='SPLY'">SHALL contain exactly one [1..1] @classCode="SPLY" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7427).</sch:assert>
      <sch:assert id="a-7428" test="@moodCode='INT'">SHALL contain exactly one [1..1] @moodCode="INT" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7428).</sch:assert>
      <sch:assert id="a-7430" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:7430).</sch:assert>
      <sch:assert id="a-7432" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:7432).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.17-errors" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.17']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.17-errors-abstract" />
      <sch:assert id="a-10507" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.17'])=1">SHALL contain exactly one [1..1] templateId (CONF:7429) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.17" (CONF:10507).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.54-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.54-errors-abstract" abstract="true">
      <sch:assert id="a-9002" test="@classCode='MANU'">SHALL contain exactly one [1..1] @classCode="MANU" (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:9002).</sch:assert>
      <sch:assert id="a-9006" test="count(cda:manufacturedMaterial)=1">SHALL contain exactly one [1..1] manufacturedMaterial (CONF:9006).</sch:assert>
      <sch:assert id="a-9007" test="cda:manufacturedMaterial[count(cda:code)=1]">This manufacturedMaterial SHALL contain exactly one [1..1] code, which SHALL be selected from ValueSet Vaccine Administered Value Set 2.16.840.1.113883.3.88.12.80.22 DYNAMIC (CONF:9007).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.54-errors" context="cda:manufacturedProduct[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.54']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.54-errors-abstract" />
      <sch:assert id="a-10499" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.54'])=1">SHALL contain exactly one [1..1] templateId (CONF:9004) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.54" (CONF:10499).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.19-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.19-errors-abstract" abstract="true">
      <sch:assert id="a-7480" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7480).</sch:assert>
      <sch:assert id="a-7481" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7481).</sch:assert>
      <sch:assert id="a-7483" test="count(cda:id)=1">SHALL contain exactly one [1..1] id (CONF:7483).</sch:assert>
      <sch:assert id="a-7487" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:7487).</sch:assert>
      <sch:assert id="a-16886" test="count(cda:code[@code=document('2.16.840.1.113883.3.88.12.3221.7.2.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.3.88.12.3221.7.2']/svs:ConceptList/svs:Concept/@code])=1">SHALL contain exactly one [1..1] code, which SHOULD be selected from ValueSet Problem Type 2.16.840.1.113883.3.88.12.3221.7.2 STATIC 2012-06-01 (CONF:16886).</sch:assert>
      <sch:assert id="a-19105" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19105).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.19-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.19']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.19-errors-abstract" />
      <sch:assert id="a-10502" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.19'])=1">SHALL contain exactly one [1..1] templateId (CONF:7482) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.19" (CONF:10502).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.24-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.24-errors-abstract" abstract="true">
      <sch:assert id="a-7490" test="@classCode='MANU'">SHALL contain exactly one [1..1] @classCode="MANU" (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:7490).</sch:assert>
      <sch:assert id="a-7492" test="count(cda:playingEntity)=1">SHALL contain exactly one [1..1] playingEntity (CONF:7492).</sch:assert>
      <sch:assert id="a-7493" test="cda:playingEntity[count(cda:code)=1]">This playingEntity/code is used to supply a coded term for the drug vehicle.
This playingEntity SHALL contain exactly one [1..1] code (CONF:7493).</sch:assert>
      <sch:assert id="a-19137" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:19137).</sch:assert>
      <sch:assert id="a-19138" test="cda:code[@code='412307009' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="412307009" Drug Vehicle (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:19138).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.24-errors" context="cda:participantRole[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.24']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.24-errors-abstract" />
      <sch:assert id="a-10493" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.24'])=1">SHALL contain exactly one [1..1] templateId (CONF:7495) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.24" (CONF:10493).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.8-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.8-errors-abstract" abstract="true">
      <sch:assert id="a-7345" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7345).</sch:assert>
      <sch:assert id="a-7346" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7346).</sch:assert>
      <sch:assert id="a-7352" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:7352).</sch:assert>
      <sch:assert id="a-7356" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet Problem Severity 2.16.840.1.113883.3.88.12.3221.6.8 DYNAMIC (CONF:7356).</sch:assert>
      <sch:assert id="a-19115" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19115).</sch:assert>
      <sch:assert id="a-19168" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:19168).</sch:assert>
      <sch:assert id="a-19169" test="cda:code[@code='SEV' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="SEV" (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:19169).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.8-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.8']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.8-errors-abstract" />
      <sch:assert id="a-10525" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.8'])=1">SHALL contain exactly one [1..1] templateId (CONF:7347) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.8" (CONF:10525).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.32-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.32-errors-abstract" abstract="true">
      <sch:assert id="a-7758" test="@classCode='SDLOC'">SHALL contain exactly one [1..1] @classCode="SDLOC" (CodeSystem: RoleCode 2.16.840.1.113883.5.111 STATIC) (CONF:7758).</sch:assert>
      <sch:assert id="a-16850" test="count(cda:code[@code=document('2.16.840.1.113883.1.11.20275.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.1.11.20275']/svs:ConceptList/svs:Concept/@code])=1">SHALL contain exactly one [1..1] code, which SHALL be selected from ValueSet HealthcareServiceLocation 2.16.840.1.113883.1.11.20275 STATIC (CONF:16850).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.32-errors" context="cda:participantRole[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.32']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.32-errors-abstract" />
      <sch:assert id="a-10524" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.32'])=1">SHALL contain exactly one [1..1] templateId (CONF:7635) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.32" (CONF:10524).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.37-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.37-errors-abstract" abstract="true">
      <sch:assert id="a-7900" test="@classCode='MANU'">SHALL contain exactly one [1..1] @classCode="MANU" Manufactured Product (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:7900).</sch:assert>
      <sch:assert id="a-7902" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:7902).</sch:assert>
      <sch:assert id="a-7903" test="count(cda:playingDevice)=1">SHALL contain exactly one [1..1] playingDevice (CONF:7903).</sch:assert>
      <sch:assert id="a-7905" test="count(cda:scopingEntity)=1">SHALL contain exactly one [1..1] scopingEntity (CONF:7905).</sch:assert>
      <sch:assert id="a-7908" test="cda:scopingEntity[count(cda:id) &gt; 0]">This scopingEntity SHALL contain at least one [1..*] id (CONF:7908).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.37-errors" context="cda:participantRole[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.37']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.37-errors-abstract" />
      <sch:assert id="a-10522" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.37'])=1">SHALL contain exactly one [1..1] templateId (CONF:7901) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.37" (CONF:10522).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.80-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.80-errors-abstract" abstract="true">
      <sch:assert id="a-14889" test="@classCode='ACT'">SHALL contain exactly one [1..1] @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:14889).</sch:assert>
      <sch:assert id="a-14890" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:14890).</sch:assert>
      <sch:assert id="a-14898" test="count(cda:entryRelationship[@typeCode='SUBJ'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.4'])=1]) &gt; 0">SHALL contain at least one [1..*] entryRelationship (CONF:14892) such that it SHALL contain exactly one [1..1] @typeCode="SUBJ" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:14893). SHALL contain exactly one [1..1] Problem Observation (templateId:2.16.840.1.113883.10.20.22.4.4) (CONF:14898).</sch:assert>
      <sch:assert id="a-19182" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:19182).</sch:assert>
      <sch:assert id="a-19183" test="cda:code[@code='29308-4' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL contain exactly one [1..1] @code="29308-4" Diagnosis (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:19183).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.80-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.80 ']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.80-errors-abstract" />
      <sch:assert id="a-14896" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.80'])=1">SHALL contain exactly one [1..1] templateId (CONF:14895) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.80" (CONF:14896).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.31-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.31-errors-abstract" abstract="true">
      <sch:assert id="a-7613" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7613).</sch:assert>
      <sch:assert id="a-7614" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7614).</sch:assert>
      <sch:assert id="a-7615" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:7615).</sch:assert>
      <sch:assert id="a-7617" test="count(cda:value[@xsi:type='PQ'])=1">SHALL contain exactly one [1..1] value with @xsi:type="PQ" (CONF:7617).</sch:assert>
      <sch:assert id="a-7618" test=".">This value SHALL contain exactly one [1..1] @unit="1", which SHALL be selected from ValueSet AgePQ_UCUM 2.16.840.1.113883.11.20.9.21 DYNAMIC (CONF:7618).</sch:assert>
      <sch:assert id="a-15965" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:15965).</sch:assert>
      <sch:assert id="a-15966" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:15966).</sch:assert>
      <sch:assert id="a-16776" test="cda:code[@code='445518008' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL contain exactly one [1..1] @code="445518008" Age At Onset (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:16776).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.31-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.31']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.31-errors-abstract" />
      <sch:assert id="a-10487" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.31'])=1">SHALL contain exactly one [1..1] templateId (CONF:7899) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.31" (CONF:10487).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.5-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.5-errors-abstract" abstract="true">
      <sch:assert id="a-9057" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:9057).</sch:assert>
      <sch:assert id="a-9072" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:9072).</sch:assert>
      <sch:assert id="a-9074" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:9074).</sch:assert>
      <sch:assert id="a-9075" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet HealthStatus 2.16.840.1.113883.1.11.20.12 DYNAMIC (CONF:9075).</sch:assert>
      <sch:assert id="a-19103" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19103).</sch:assert>
      <sch:assert id="a-19143" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:19143).</sch:assert>
      <sch:assert id="a-19144" test="cda:code[@code='11323-3' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL contain exactly one [1..1] @code="11323-3" Health status (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:19144).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.5-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.5']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.5-errors-abstract" />
      <sch:assert id="a-16757" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.5'])=1">SHALL contain exactly one [1..1] templateId (CONF:16756) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.5" (CONF:16757).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.28-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.28-errors-abstract" abstract="true">
      <sch:assert id="a-7318" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:7318).</sch:assert>
      <sch:assert id="a-7319" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:7319).</sch:assert>
      <sch:assert id="a-7320" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:7320).</sch:assert>
      <sch:assert id="a-7321" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:7321).</sch:assert>
      <sch:assert id="a-7322" test="count(cda:value[@xsi:type='CE'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CE", where the @code SHALL be selected from ValueSet HITSPProblemStatus 2.16.840.1.113883.3.88.12.80.68 DYNAMIC (CONF:7322).</sch:assert>
      <sch:assert id="a-19087" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19087).</sch:assert>
      <sch:assert id="a-19131" test="cda:code[@code='33999-4' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL contain exactly one [1..1] @code="33999-4" Status (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:19131).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.28-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.28']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.28-errors-abstract" />
      <sch:assert id="a-10490" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.28'])=1">SHALL contain exactly one [1..1] templateId (CONF:7317) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.28" (CONF:10490).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.86-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.86-errors-abstract" abstract="true">
      <sch:assert id="a-16715" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:16715).</sch:assert>
      <sch:assert id="a-16716" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:16716).</sch:assert>
      <sch:assert id="a-16720" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:16720).</sch:assert>
      <sch:assert id="a-16724" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:16724).</sch:assert>
      <sch:assert id="a-16754" test="count(cda:value) &gt; 0">SHALL contain at least one [1..*] value (CONF:16754).</sch:assert>
      <sch:assert id="a-19089" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19089).</sch:assert>
      <sch:assert id="a-19178" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:19178).</sch:assert>
      <sch:assert id="a-19179" test="cda:code[@code]">This code SHALL contain exactly one [1..1] @code (CONF:19179).</sch:assert>
      <sch:assert id="a-19180" test="count(cda:code[@codeSystem])=0 or cda:code[@codeSystem='2.16.840.1.113883.6.1'] or cda:code[@codeSystem='2.16.840.1.113883.6.96']">Such that the @code SHALL be from LOINC (CodeSystem: 2.16.840.1.113883.6.1) or SNOMED CT (CodeSystem: 2.16.840.1.113883.6.96) and represents components of the scale (CONF:19180).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.86-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.86']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.86-errors-abstract" />
      <sch:assert id="a-16723" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.86'])=1">SHALL contain exactly one [1..1] templateId (CONF:16722) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.86" (CONF:16723).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.85-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.85-errors-abstract" abstract="true">
      <sch:assert id="a-16558" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:16558).</sch:assert>
      <sch:assert id="a-16559" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:16559).</sch:assert>
      <sch:assert id="a-16561" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:16561).</sch:assert>
      <sch:assert id="a-16562" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD" (CONF:16562).</sch:assert>
      <sch:assert id="a-16563" test="cda:value[@code]">This value SHALL contain exactly one [1..1] @code, which SHALL be selected from ValueSet Tobacco Use 2.16.840.1.113883.11.20.9.41 DYNAMIC (CONF:16563).</sch:assert>
      <sch:assert id="a-16564" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:16564).</sch:assert>
      <sch:assert id="a-16565" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:16565).</sch:assert>
      <sch:assert id="a-19118" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19118).</sch:assert>
      <sch:assert id="a-19174" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:19174).</sch:assert>
      <sch:assert id="a-19175" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:19175).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.85-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.85']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.85-errors-abstract" />
      <sch:assert id="a-16567" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.85'])=1">SHALL contain exactly one [1..1] templateId (CONF:16566) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.85" (CONF:16567).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.50-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.50-errors-abstract" abstract="true">
      <sch:assert id="a-8745" test="@classCode='SPLY'">SHALL contain exactly one [1..1] @classCode="SPLY" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8745).</sch:assert>
      <sch:assert id="a-8746" test="@moodCode and @moodCode=document('2.16.840.1.113883.11.20.9.18.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.11.20.9.18']/svs:ConceptList/svs:Concept/@code">SHALL contain exactly one [1..1] @moodCode, which SHALL be selected from ValueSet MoodCodeEvnInt 2.16.840.1.113883.11.20.9.18 STATIC 2011-04-03 (CONF:8746).</sch:assert>
      <sch:assert id="a-8748" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8748).</sch:assert>
      <sch:assert id="a-8749" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:8749).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.50-errors" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.50']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.50-errors-abstract" />
      <sch:assert id="a-10509" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.50'])=1">SHALL contain exactly one [1..1] templateId (CONF:8747) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.50" (CONF:10509).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.72-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.72-errors-abstract" abstract="true">
      <sch:assert id="a-14219" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:14219).</sch:assert>
      <sch:assert id="a-14220" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:14220).</sch:assert>
      <sch:assert id="a-14223" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:14223).</sch:assert>
      <sch:assert id="a-14227" test="count(cda:participant) &gt; 0">SHALL contain at least one [1..*] participant (CONF:14227).</sch:assert>
      <sch:assert id="a-14228" test="cda:participant[count(cda:participantRole)=1]">Such participants SHALL contain exactly one [1..1] participantRole (CONF:14228).</sch:assert>
      <sch:assert id="a-14229" test="cda:participant/cda:participantRole[@classCode='IND']">This participantRole SHALL contain exactly one [1..1] @classCode="IND" (CONF:14229).</sch:assert>
      <sch:assert id="a-14230" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:14230).</sch:assert>
      <sch:assert id="a-14233" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:14233).</sch:assert>
      <sch:assert id="a-14599" test="count(cda:value)=1">SHALL contain exactly one [1..1] value (CONF:14599).</sch:assert>
      <sch:assert id="a-14831" test="not(cda:participant/cda:time) or cda:participant/cda:time[count(cda:low)=1]">The time, if present, SHALL contain exactly one [1..1] low (CONF:14831).</sch:assert>
      <sch:assert id="a-19090" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19090).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.72-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.72']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.72-errors-abstract" />
      <sch:assert id="a-14222" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.72'])=1">SHALL contain exactly one [1..1] templateId (CONF:14221) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.72" (CONF:14222).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.17.2.1-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.1-errors-abstract" abstract="true">
      <sch:assert id="a-4142" test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='reporting parameters'])=1">SHALL contain exactly one [1..1] title="Reporting Parameters" (CONF:4142).</sch:assert>
      <sch:assert id="a-4143" test="count(cda:text)=1">SHALL contain exactly one [1..1] text (CONF:4143).</sch:assert>
      <sch:assert id="a-17496" test="count(cda:entry[@typeCode='DRIV'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8'])=1])=1">SHALL contain exactly one [1..1] entry (CONF:3277) such that it SHALL contain exactly one [1..1] @typeCode="DRIV" Is derived from (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:3278). SHALL contain exactly one [1..1] Reporting Parameters Act (templateId:2.16.840.1.113883.10.20.17.3.8) (CONF:17496).</sch:assert>
      <sch:assert id="a-18191" test="count(cda:code[@code='55187-9'][@codeSystem='2.16.840.1.113883.6.1'])">SHALL contain exactly one [1..1] code (CONF:18191).</sch:assert>
      <sch:assert id="a-19229" test="cda:code[@code='55187-9' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL contain exactly one [1..1] @code="55187-9" Reporting Parameters (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:19229).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.1-errors" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.2.1-errors-abstract" />
      <sch:assert id="a-14612" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.17.2.1'])=1">SHALL contain exactly one [1..1] templateId (CONF:14611) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.17.2.1" (CONF:14612).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.17.3.8-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.17.3.8-errors-abstract" abstract="true">
      <sch:assert id="a-3269" test="@classCode='ACT'">SHALL contain exactly one [1..1] @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:3269).</sch:assert>
      <sch:assert id="a-3270" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:3270).</sch:assert>
      <sch:assert id="a-3272" test="count(cda:code[@code='252116004'][@codeSystem='2.16.840.1.113883.6.96'])=1">SHALL contain exactly one [1..1] code="252116004" Observation Parameters (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:3272).</sch:assert>
      <sch:assert id="a-3273" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1] effectiveTime (CONF:3273).</sch:assert>
      <sch:assert id="a-3274" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL contain exactly one [1..1] low (CONF:3274).</sch:assert>
      <sch:assert id="a-3275" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL contain exactly one [1..1] high (CONF:3275).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.17.3.8-errors" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.3.8-errors-abstract" />
      <sch:assert id="a-18099" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.17.3.8'])=1">SHALL contain exactly one [1..1] templateId (CONF:18098) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.17.3.8" (CONF:18099).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.46-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.46-errors-abstract" abstract="true">
      <sch:assert id="a-8586" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8586).</sch:assert>
      <sch:assert id="a-8587" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:8587).</sch:assert>
      <sch:assert id="a-8589" test="count(cda:code[@code=document('2.16.840.1.113883.3.88.12.3221.7.2.xml')/svs:RetrieveValueSetResponse/svs:ValueSet[@id='2.16.840.1.113883.3.88.12.3221.7.2']/svs:ConceptList/svs:Concept/@code])=1">SHALL contain exactly one [1..1] code, which SHOULD be selected from ValueSet Problem Type 2.16.840.1.113883.3.88.12.3221.7.2 STATIC 2012-06-01 (CONF:8589).</sch:assert>
      <sch:assert id="a-8590" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:8590).</sch:assert>
      <sch:assert id="a-8591" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet Problem 2.16.840.1.113883.3.88.12.3221.7.4 DYNAMIC (CONF:8591).</sch:assert>
      <sch:assert id="a-8592" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id (CONF:8592).</sch:assert>
      <sch:assert id="a-19098" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19098).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.46-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.46']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.46-errors-abstract" />
      <sch:assert id="a-10496" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.46'])=1">SHALL contain exactly one [1..1] templateId (CONF:8599) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.46" (CONF:10496).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.47-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.47-errors-abstract" abstract="true">
      <sch:assert id="a-8621" test="@classCode='OBS'">SHALL contain exactly one [1..1] @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:8621).</sch:assert>
      <sch:assert id="a-8622" test="@moodCode='EVN'">SHALL contain exactly one [1..1] @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC) (CONF:8622).</sch:assert>
      <sch:assert id="a-8625" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1] statusCode (CONF:8625).</sch:assert>
      <sch:assert id="a-8626" test="count(cda:value[@code='419099009'][@xsi:type='CD'])=1">SHALL contain exactly one [1..1] value="419099009" Dead with @xsi:type="CD" (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:8626).</sch:assert>
      <sch:assert id="a-19097" test="cda:statusCode[@code='completed']">This statusCode SHALL contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:19097).</sch:assert>
      <sch:assert id="a-19141" test="count(cda:code)=1">SHALL contain exactly one [1..1] code (CONF:19141).</sch:assert>
      <sch:assert id="a-19142" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC) (CONF:19142).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.47-errors" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.47']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.47-errors-abstract" />
      <sch:assert id="a-10495" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.47'])=1">SHALL contain exactly one [1..1] templateId (CONF:8623) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.22.4.47" (CONF:10495).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.104-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.104-warnings-abstract" abstract="true">
      <sch:assert id="a-16391" test="cda:effectiveTime[count(cda:high) &lt; 2]">This effectiveTime SHOULD contain zero or one [0..1] high (CONF:16391).</sch:assert>
      <sch:assert id="a-16399" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:16396) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:16397). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:16398). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:16399).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.104-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.104']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.61-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.61-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-warnings-abstract" />
      <sch:assert id="a-11384" test="cda:effectiveTime[count(cda:high) &lt; 2]">This effectiveTime SHOULD contain zero or one [0..1] high (CONF:11384).</sch:assert>
      <sch:assert id="a-11479" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:11396) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:11397). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:11398). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:11479).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.61-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.61']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.61-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.41-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.41-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.41-warnings" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.41']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.41-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.65-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.65-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.41-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.65-warnings" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.65']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.65-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.83-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.83-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.83-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.83']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.83-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.84-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.84-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.84-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.84']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.84-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.9-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.9-warnings-abstract" abstract="true">
      <sch:assert id="a-7330" test="count(cda:text) &lt; 2">SHOULD contain zero or one [0..1] text (CONF:7330).</sch:assert>
      <sch:assert id="a-7332" test="count(cda:effectiveTime) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:7332).</sch:assert>
      <sch:assert id="a-7333" test="not(cda:effectiveTime) or cda:effectiveTime[count(cda:low) &lt; 2]">The effectiveTime, if present, SHOULD contain zero or one [0..1] low (CONF:7333).</sch:assert>
      <sch:assert id="a-7334" test="not(cda:effectiveTime) or cda:effectiveTime[count(cda:high) &lt; 2]">The effectiveTime, if present, SHOULD contain zero or one [0..1] high (CONF:7334).</sch:assert>
      <sch:assert id="a-15917" test="not(cda:text) or cda:text[count(cda:reference) &lt; 2]">The text, if present, SHOULD contain zero or one [0..1] reference (CONF:15917).</sch:assert>
      <sch:assert id="a-15918" test="not(cda:text/cda:reference) or cda:text/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:15918).</sch:assert>
      <sch:assert id="a-15922" test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.8'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:7580) such that it SHALL contain exactly one [1..1] @typeCode="SUBJ" Has subject (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:7581). SHALL contain exactly one [1..1] @inversionInd="true" TRUE (CONF:10375). SHALL contain exactly one [1..1] Severity Observation (templateId:2.16.840.1.113883.10.20.22.4.8) (CONF:15922).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.9-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.9']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.9-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.85-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.85-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.9-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.85-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.85-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.44-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.44-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.44']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.1-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.1-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.1-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.1-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.63-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.63-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.41-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.63-warnings" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.63']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.63-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.14-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.14-warnings-abstract" abstract="true">
      <sch:assert id="a-7662" test="count(cda:effectiveTime) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:7662).</sch:assert>
      <sch:assert id="a-7683" test="not(cda:targetSiteCode) or cda:targetSiteCode">SHOULD contain zero or more [0..*] targetSiteCode (CONF:7683).</sch:assert>
      <sch:assert id="a-7716" test="not(cda:specimen/cda:specimenRole) or cda:specimen/cda:specimenRole[not(cda:id) or cda:id]">This specimenRole SHOULD contain zero or more [0..*] id (CONF:7716).</sch:assert>
      <sch:assert id="a-7720" test="not(cda:performer[count(cda:assignedEntity)=1]) or cda:performer[count(cda:assignedEntity)=1]">SHOULD contain zero or more [0..*] performer (CONF:7718) such that it SHALL contain exactly one [1..1] assignedEntity (CONF:7720).</sch:assert>
      <sch:assert id="a-7722" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:id) &gt; 0]">This assignedEntity SHALL contain at least one [1..*] id (CONF:7722).</sch:assert>
      <sch:assert id="a-7731" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:addr)=1]">This assignedEntity SHALL contain exactly one [1..1] addr (CONF:7731).</sch:assert>
      <sch:assert id="a-7732" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:telecom)=1]">This assignedEntity SHALL contain exactly one [1..1] telecom (CONF:7732).</sch:assert>
      <sch:assert id="a-7733" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:representedOrganization) &lt; 2]">This assignedEntity SHOULD contain zero or one [0..1] representedOrganization (CONF:7733).</sch:assert>
      <sch:assert id="a-7734" test="not(cda:performer/cda:assignedEntity/cda:representedOrganization) or cda:performer/cda:assignedEntity/cda:representedOrganization[not(cda:id) or cda:id]">The representedOrganization, if present, SHOULD contain zero or more [0..*] id (CONF:7734).</sch:assert>
      <sch:assert id="a-7736" test="not(cda:performer/cda:assignedEntity/cda:representedOrganization) or cda:performer/cda:assignedEntity/cda:representedOrganization[count(cda:addr)=1]">The representedOrganization, if present, SHALL contain exactly one [1..1] addr (CONF:7736).</sch:assert>
      <sch:assert id="a-7737" test="not(cda:performer/cda:assignedEntity/cda:representedOrganization) or cda:performer/cda:assignedEntity/cda:representedOrganization[count(cda:telecom)=1]">The representedOrganization, if present, SHALL contain exactly one [1..1] telecom (CONF:7737).</sch:assert>
      <sch:assert id="a-16082" test="not(cda:targetSiteCode) or cda:targetSiteCode[@code]">The targetSiteCode, if present, SHALL contain exactly one [1..1] @code, which SHALL be selected from ValueSet Body Site Value Set 2.16.840.1.113883.3.88.12.3221.8.9 DYNAMIC (CONF:16082).</sch:assert>
      <sch:assert id="a-19203" test="cda:code[count(cda:originalText) &lt; 2]">This code SHOULD contain zero or one [0..1] originalText (CONF:19203).</sch:assert>
      <sch:assert id="a-19204" test="not(cda:code/cda:originalText) or cda:code/cda:originalText[count(cda:reference) &lt; 2]">The originalText, if present, SHOULD contain zero or one [0..1] reference (CONF:19204).</sch:assert>
      <sch:assert id="a-19205" test="not(cda:code/cda:originalText/cda:reference) or cda:code/cda:originalText/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:19205).</sch:assert>
      <sch:assert id="a-19207" test="count(cda:code[@codeSystem])=1 or cda:code[@codeSystem='2.16.840.1.113883.6.1'] or cda:code[@codeSystem='2.16.840.1.113883.6.96'] or cda:code[@codeSystem='2.16.840.1.113883.6.12'] or cda:code[@codeSystem='2.16.840.1.113883.6.104'] or cda:code[@codeSystem='2.16.840.1.113883.6.4']">This code in a procedure activity SHOULD be selected from LOINC (codeSystem 2.16.840.1.113883.6.1) or SNOMED CT (CodeSystem: 2.16.840.1.113883.6.96), and MAY be selected from CPT-4 (CodeSystem: 2.16.840.1.113883.6.12), ICD9 Procedures (CodeSystem: 2.16.840.1.113883.6.104), ICD10 Procedure Coding System (CodeSystem: 2.16.840.1.113883.6.4) (CONF:19207).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.14-warnings" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.14']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.14-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.66-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.66-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.14-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.66-warnings" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.66']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.66-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.2-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.2-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.2-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.2-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.64-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.64-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.14-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.64-warnings" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.64-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.88-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.88-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.88-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.88']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.88-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.89-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.89-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.89-warnings" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.89']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.89-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.62-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.62-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-warnings-abstract" />
      <sch:assert id="a-11445" test="cda:effectiveTime[count(cda:high) &lt; 2]">This effectiveTime SHOULD contain zero or one [0..1] high (CONF:11445).</sch:assert>
      <sch:assert id="a-11477" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:11457) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:11458). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:11459). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:11477).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.62-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.62']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.62-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.4-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.4-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.4-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.4']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.4-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.82-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.82-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.82-warnings" context="cda:Participant2[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.82']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.82-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.2-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.2-warnings-abstract" abstract="true">
      <sch:assert id="a-7138" test="count(cda:text) &lt; 2">SHOULD contain zero or one [0..1] text (CONF:7138).</sch:assert>
      <sch:assert id="a-7147" test="not(cda:interpretationCode) or cda:interpretationCode">SHOULD contain zero or more [0..*] interpretationCode (CONF:7147).</sch:assert>
      <sch:assert id="a-7150" test="not(cda:referenceRange) or cda:referenceRange">SHOULD contain zero or more [0..*] referenceRange (CONF:7150).</sch:assert>
      <sch:assert id="a-7151" test="not(cda:referenceRange) or cda:referenceRange[count(cda:observationRange)=1]">The referenceRange, if present, SHALL contain exactly one [1..1] observationRange (CONF:7151).</sch:assert>
      <sch:assert id="a-7152" test="not(cda:referenceRange/cda:observationRange/cda:code)">This observationRange SHALL NOT contain [0..0] code (CONF:7152).</sch:assert>
      <sch:assert id="a-15924" test="not(cda:text) or cda:text[count(cda:reference) &lt; 2]">The text, if present, SHOULD contain zero or one [0..1] reference (CONF:15924).</sch:assert>
      <sch:assert id="a-15925" test="not(cda:text/cda:reference) or cda:text/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:15925).</sch:assert>
      <sch:assert id="a-19211" test="(count(cda:code[@codeSystem])=0 and cda:code[@nullFlavor]) or cda:code[@codeSystem='2.16.840.1.113883.6.1'] or cda:code[@codeSystem='2.16.840.1.113883.6.96']">SHOULD be from LOINC (CodeSystem: 2.16.840.1.113883.6.1) or SNOMED CT (CodeSystem: 2.16.840.1.113883.6.96) (CONF:19211).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.2-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.87-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.87-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-warnings-abstract" />
      <sch:assert id="a-16702" test="count(cda:value[@xsi-type='PQ'])=0 or count(cda:value[@xsi-type='PQ'])=1">If xsi:type=PQ, then @units shall be drawn from Unified Code for Units of Measure (UCUM) 2.16.840.1.113883.6.8 code system. Additional constraint is dependent on criteria in the corresponding eMeasure (CONF:16702).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.87-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.87']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.87-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.91-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.91-warnings-abstract" abstract="true">
      <sch:assert id="a-13286" test="count(cda:effectiveTime) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:13286).</sch:assert>
      <sch:assert id="a-13287" test="count(cda:value) &lt; 2">SHOULD contain zero or one [0..1] value (CONF:13287).</sch:assert>
      <sch:assert id="a-13292" test="not(cda:effectiveTime) or cda:effectiveTime[count(cda:low)=1]">The effectiveTime, if present, SHALL contain exactly one [1..1] low (CONF:13292).</sch:assert>
      <sch:assert id="a-13293" test="not(cda:effectiveTime) or cda:effectiveTime[count(cda:high)=1]">The effectiveTime, if present, SHALL contain exactly one [1..1] high (CONF:13293).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.91-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.91']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.91-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.93-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.93-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.93-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.93']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.93-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.38-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.38-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.38-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.38']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.38-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.16-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.16-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-warnings-abstract" />
      <sch:assert id="a-11744" test="cda:effectiveTime[count(cda:high) &lt; 2]">This effectiveTime SHOULD contain zero or one [0..1] high (CONF:11744).</sch:assert>
      <sch:assert id="a-11752" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:11749) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:11750). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:11751). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:11752).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.16-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.16']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.16-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.40-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.40-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-warnings-abstract" />
      <sch:assert id="a-19212" test="(count(cda:code[@codeSystem])=0 and cda:code[@nullFlavor]) or cda:code[@codeSystem='2.16.840.1.113883.6.1']">Laboratory results SHOULD be from LOINC (CodeSystem: 2.16.840.1.113883.6.1) or other constrained terminology named by the US Department of Health and Human Services Office of National Coordinator or other federal agency. Local and/or regional codes for laboratory results are allowed. The Local and/or regional codes SHOULD be sent in the translation element. See the Local code example figure (CONF:19212).</sch:assert>      
      <sch:assert id="a-16698" test="count(cda:value[@xsi-type='PQ'])=0 or count(cda:value[@xsi-type='PQ'])=1">If xsi:type=PQ, then @units shall be drawn from Unified Code for Units of Measure (UCUM) 2.16.840.1.113883.6.8 code system. Additional constraint is dependent on criteria in the corresponding eMeasure (CONF:16698).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.40-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.40']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.40-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.15-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.15-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-warnings-abstract" />
      <sch:assert id="a-11778" test="cda:effectiveTime[count(cda:high) &lt; 2]">This effectiveTime SHOULD contain zero or one [0..1] high (CONF:11778).</sch:assert>
      <sch:assert id="a-11786" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:11783) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:11784). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:11785). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:11786).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.15-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.15']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.15-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.39-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.39-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.39-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.39']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.39-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.3-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.3-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.3-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.3']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.3-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.49-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.49-warnings-abstract" abstract="true">
      <sch:assert id="a-8714" test="count(cda:code) &lt; 2">SHOULD contain zero or one [0..1] code, which SHOULD be selected from ValueSet EncounterTypeCode 2.16.840.1.113883.3.88.12.80.32 DYNAMIC (CONF:8714).</sch:assert>
      <sch:assert id="a-8719" test="not(cda:code) or cda:code[count(cda:originalText) &lt; 2]">The code, if present, SHOULD contain zero or one [0..1] originalText (CONF:8719).</sch:assert>
      <sch:assert id="a-8720" test="not(cda:code/cda:reference[@value='']) or cda:code/cda:reference[@value=''][not(cda:reference[@value]) or cda:reference[@value]]">The originalText, if present, SHOULD contain zero or one [0..1] reference/@value (CONF:8720).</sch:assert>
      <sch:assert id="a-15970" test="not(cda:code/cda:originalText) or cda:code/cda:originalText[count(cda:reference) &lt; 2]">The originalText, if present, SHOULD contain zero or one [0..1] reference (CONF:15970).</sch:assert>
      <sch:assert id="a-15971" test="not(cda:code/cda:originalText/cda:reference) or cda:code/cda:originalText/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:15971).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.49-warnings" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.49']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.49-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.23-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.23-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.49-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.23-warnings" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.23-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.21-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.21-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.49-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.21-warnings" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.21']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.21-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.40-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.40-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.40-warnings" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.40']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.40-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.24-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.24-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.40-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.24-warnings" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.24']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.24-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.22-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.22-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.40-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.22-warnings" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.22']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.22-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.37-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.37-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.37-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.37']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.37-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.4-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.4-warnings-abstract" abstract="true">
      <sch:assert id="a-9050" test="count(cda:effectiveTime) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:9050).</sch:assert>
      <sch:assert id="a-9185" test="count(cda:text) &lt; 2">SHOULD contain zero or one [0..1] text (CONF:9185).</sch:assert>
      <sch:assert id="a-15587" test="not(cda:text) or cda:text[count(cda:reference) &lt; 2]">The text, if present, SHOULD contain zero or one [0..1] reference (CONF:15587).</sch:assert>
      <sch:assert id="a-15588" test="not(cda:text/cda:reference) or cda:text/cda:reference[@value]">The reference, if present, SHALL contain exactly one [1..1] @value (CONF:15588).</sch:assert>
      <sch:assert id="a-15603" test="not(cda:effectiveTime) or cda:effectiveTime[count(cda:low)=1]">The effectiveTime, if present, SHALL contain exactly one [1..1] low (CONF:15603).</sch:assert>
      <sch:assert id="a-15604" test="not(cda:effectiveTime) or cda:effectiveTime[count(cda:high) &lt; 2]">The effectiveTime, if present, SHOULD contain zero or one [0..1] high (CONF:15604).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.4-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.4']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.11-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.11-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.11-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.11-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.13-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.13-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.13-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.13']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.13-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.14-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.14-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.14-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.14']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.14-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.16-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.16-warnings-abstract" abstract="true">
      <sch:assert id="a-7501" test="count(cda:text) &lt; 2">SHOULD contain zero or one [0..1] text (CONF:7501).</sch:assert>
      <sch:assert id="a-7516" test="count(cda:doseQuantity[@xsi:type='IVL&lt;PQ&gt;']) &lt; 2">SHOULD contain zero or one [0..1] doseQuantity (CONF:7516).</sch:assert>
      <sch:assert id="a-7526" test=".">The doseQuantity, if present, SHOULD contain zero or one [0..1] @unit="1", which SHALL be selected from ValueSet UCUM Units of Measure (case sensitive) 2.16.840.1.113883.1.11.12839 DYNAMIC (CONF:7526).</sch:assert>
      <sch:assert id="a-9106" test="count(cda:effectiveTime[@operator='A']) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:7513) such that it SHALL contain exactly one [1..1] @operator="A" (CONF:9106).</sch:assert>
      <sch:assert id="a-15977" test="not(cda:text) or cda:text[count(cda:reference) &lt; 2]">The text, if present, SHOULD contain zero or one [0..1] reference (CONF:15977).</sch:assert>
      <sch:assert id="a-15978" test="not(cda:text/cda:reference) or cda:text/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:15978).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.16-warnings" context="cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.16']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.16-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.41-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.41-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.16-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.41-warnings" context="cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.41']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.41-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.90-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.90-warnings-abstract" abstract="true">
      <sch:assert id="a-16318" test="not(cda:participant) or cda:participant">SHOULD contain zero or more [0..*] participant (CONF:16318).</sch:assert>
      <sch:assert id="a-16319" test="not(cda:participant) or cda:participant[@typeCode='CSM']">The participant, if present, SHALL contain exactly one [1..1] @typeCode="CSM" Consumable (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:16319).</sch:assert>
      <sch:assert id="a-16320" test="not(cda:participant) or cda:participant[count(cda:participantRole)=1]">The participant, if present, SHALL contain exactly one [1..1] participantRole (CONF:16320).</sch:assert>
      <sch:assert id="a-16321" test="not(cda:participant/cda:participantRole) or cda:participant/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" Manufactured Product (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:16321).</sch:assert>
      <sch:assert id="a-16322" test="not(cda:participant/cda:participantRole) or cda:participant/cda:participantRole[count(cda:playingEntity)=1]">This participantRole SHALL contain exactly one [1..1] playingEntity (CONF:16322).</sch:assert>
      <sch:assert id="a-16323" test="not(cda:participant/cda:participantRole/cda:playingEntity) or cda:participant/cda:participantRole/cda:playingEntity[@classCode='MMAT']">This playingEntity SHALL contain exactly one [1..1] @classCode="MMAT" Manufactured Material (CodeSystem: EntityClass 2.16.840.1.113883.5.41 STATIC) (CONF:16323).</sch:assert>
      <sch:assert id="a-16324" test="not(cda:participant/cda:participantRole/cda:playingEntity) or cda:participant/cda:participantRole/cda:playingEntity[count(cda:code)=1]">This playingEntity SHALL contain exactly one [1..1] code (CONF:16324).</sch:assert>
      <sch:assert id="a-16326" test="not(cda:participant/cda:participantRole/cda:playingEntity/cda:code) or cda:participant/cda:participantRole/cda:playingEntity/cda:code[count(cda:originalText) &lt; 2]">This code SHOULD contain zero or one [0..1] originalText (CONF:16326).</sch:assert>
      <sch:assert id="a-16327" test="not(cda:participant/cda:participantRole/cda:playingEntity/cda:code/cda:originalText) or cda:participant/cda:participantRole/cda:playingEntity/cda:code/cda:originalText[count(cda:reference) &lt; 2]">The originalText, if present, SHOULD contain zero or one [0..1] reference (CONF:16327).</sch:assert>
      <sch:assert id="a-16328" test="not(cda:participant/cda:participantRole/cda:playingEntity/cda:code/cda:originalText/cda:reference) or cda:participant/cda:participantRole/cda:playingEntity/cda:code/cda:originalText/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:16328).</sch:assert>
      <sch:assert id="a-16340" test="not(cda:entryRelationship[@inversionInd='true'][@typeCode='MFST'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.9'])=1]) or cda:entryRelationship[@inversionInd='true'][@typeCode='MFST'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.9'])=1]">SHOULD contain zero or more [0..*] entryRelationship (CONF:16337) such that it SHALL contain exactly one [1..1] @inversionInd="true" True (CONF:16338). SHALL contain exactly one [1..1] @typeCode="MFST" Is Manifestation of (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:16339). SHALL contain exactly one [1..1] Reaction Observation (templateId:2.16.840.1.113883.10.20.22.4.9) (CONF:16340).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.90-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.90']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.90-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.5-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.5-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.90-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.5-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.5']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.5-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.6-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.6-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.90-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.6-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.6']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.6-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.8-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.8-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.90-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.8-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.8']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.8-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.6-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.6-warnings-abstract" abstract="true">
      <sch:assert id="a-7362" test="count(cda:text) &lt; 2">SHOULD contain zero or one [0..1] text (CONF:7362).</sch:assert>
      <sch:assert id="a-15593" test="not(cda:text) or cda:text[count(cda:reference) &lt; 2]">The text, if present, SHOULD contain zero or one [0..1] reference (CONF:15593).</sch:assert>
      <sch:assert id="a-15594" test="not(cda:text/cda:reference) or cda:text/cda:reference[@value]">The reference, if present, SHALL contain exactly one [1..1] @value (CONF:15594).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.6-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.6']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.6-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.94-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.94-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.6-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.94-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.94']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.94-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.95-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.95-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.6-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.95-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.95']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.95-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.96-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.96-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.6-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.96-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.96']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.96-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.76-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.76-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.76-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.76']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.76-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.78-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.78-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.78-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.78']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.78-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.79-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.79-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.79-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.79']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.79-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.43-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.43-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.43-warnings" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.43']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.43-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.9-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.9-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.43-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.9-warnings" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.9']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.9-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.10-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.10-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.43-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.10-warnings" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.10']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.10-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.7-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.7-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.14-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.7-warnings" context="cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.7']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.7-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.42-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.42-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.42-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.42']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.42-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.48-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.48-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.48-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.48']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.48-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.67-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.67-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.67-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.67']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.67-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.69-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.69-warnings-abstract" abstract="true">
      <sch:assert id="a-16742" test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.86'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.86'])=1]">SHOULD contain zero or more [0..*] entryRelationship (CONF:14451) such that it SHALL contain exactly one [1..1] @typeCode="COMP" has component (CONF:16741). SHALL contain exactly one [1..1] Assessment Scale Supporting Observation (templateId:2.16.840.1.113883.10.20.22.4.86) (CONF:16742).</sch:assert>
      <sch:assert id="a-16801" test="not(cda:referenceRange/cda:observationRange) or cda:referenceRange/cda:observationRange[count(cda:text) &lt; 2]">This observationRange SHOULD contain zero or one [0..1] text (CONF:16801).</sch:assert>
      <sch:assert id="a-16802" test="not(cda:referenceRange/cda:observationRange/cda:text) or cda:referenceRange/cda:observationRange/cda:text[count(cda:reference) &lt; 2]">The text, if present, SHOULD contain zero or one [0..1] reference (CONF:16802).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.69-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.69']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.69-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.69-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.69-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.69-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.69-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.69']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.69-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.79-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.79-warnings-abstract" abstract="true">
      <sch:assert id="a-14870" test="count(cda:entryRelationship[@typeCode='CAUS'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.4'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:14868) such that it SHALL contain exactly one [1..1] @typeCode="CAUS" Is etiology for (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:14875). SHALL contain exactly one [1..1] Problem Observation (templateId:2.16.840.1.113883.10.20.22.4.4) (CONF:14870).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.79-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.79']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.79-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.54-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.54-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.79-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.54-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.54']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.54-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.51-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.51-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.51-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.51']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.51-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.55-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.55-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.55-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.55-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.42-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.42-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.42-warnings" context="cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.42']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.42-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.47-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.47-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.42-warnings-abstract" />
      <sch:assert id="a-12602" test="count(cda:doseQuantity[@xsi:type='IVL&lt;PQ&gt;']) &lt; 2">SHOULD contain zero or one [0..1] doseQuantity (CONF:12602).</sch:assert>
      <sch:assert id="a-12603" test="not(cda:doseQuantity) or cda:doseQuantity[not(@unit='1') or @unit='1']">The doseQuantity, if present, SHOULD contain zero or one [0..1] @unit="1", which SHALL be selected from ValueSet UCUM Units of Measure (case sensitive) 2.16.840.1.113883.1.11.12839 DYNAMIC (CONF:12603).</sch:assert>
      <sch:assert id="a-12637" test="count(cda:repeatNumber)=0 or count(cda:repeatNumber[count(cda:low)=1][count(cda:center)=1])">A.	In "INT" (intent) mood, the repeatNumber defines the number of allowed administrations. For example, a repeatNumber of "3" means that the substance can be administered up to 3 times (CONF:12637).</sch:assert>
      <sch:assert id="a-12638" test="count(cda:repeatNumber)=0 or count(cda:repeatNumber[count(cda:low)=1][count(cda:center)=1])">In "EVN" (event) mood, the repeatNumber is the number of occurrences. For example, a repeatNumber of "3" in a substance administration event means that the current administration is the 3rd in a series (CONF:12638).</sch:assert>
      <sch:assert id="a-13849" test="count(cda:effectiveTime[@xsi:type='PIVL_TS or EIVL_TS']) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:13849).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.47-warnings" context="cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.47']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.47-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.13-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.13-warnings-abstract" abstract="true">
      <sch:assert id="a-8246" test="count(cda:effectiveTime) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:8246).</sch:assert>
      <sch:assert id="a-8250" test="not(cda:targetSiteCode) or cda:targetSiteCode">SHOULD contain zero or more [0..*] targetSiteCode (CONF:8250).</sch:assert>
      <sch:assert id="a-8251" test="not(cda:performer) or cda:performer">SHOULD contain zero or more [0..*] performer (CONF:8251).</sch:assert>
      <sch:assert id="a-8252" test="not(cda:performer) or cda:performer[count(cda:assignedEntity)=1]">The performer, if present, SHALL contain exactly one [1..1] assignedEntity (CONF:8252).</sch:assert>
      <sch:assert id="a-8253" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:id) &gt; 0]">This assignedEntity SHALL contain at least one [1..*] id (CONF:8253).</sch:assert>
      <sch:assert id="a-8254" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:addr)=1]">This assignedEntity SHALL contain exactly one [1..1] addr (CONF:8254).</sch:assert>
      <sch:assert id="a-8255" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:telecom)=1]">This assignedEntity SHALL contain exactly one [1..1] telecom (CONF:8255).</sch:assert>
      <sch:assert id="a-8256" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:representedOrganization) &lt; 2]">This assignedEntity SHOULD contain zero or one [0..1] representedOrganization (CONF:8256).</sch:assert>
      <sch:assert id="a-8257" test="not(cda:performer/cda:assignedEntity/cda:representedOrganization) or cda:performer/cda:assignedEntity/cda:representedOrganization[not(cda:id) or cda:id]">The representedOrganization, if present, SHOULD contain zero or more [0..*] id (CONF:8257).</sch:assert>
      <sch:assert id="a-8259" test="not(cda:performer/cda:assignedEntity/cda:representedOrganization) or cda:performer/cda:assignedEntity/cda:representedOrganization[count(cda:addr)=1]">The representedOrganization, if present, SHALL contain exactly one [1..1] addr (CONF:8259).</sch:assert>
      <sch:assert id="a-8260" test="not(cda:performer/cda:assignedEntity/cda:representedOrganization) or cda:performer/cda:assignedEntity/cda:representedOrganization[count(cda:telecom)=1]">The representedOrganization, if present, SHALL contain exactly one [1..1] telecom (CONF:8260).</sch:assert>
      <sch:assert id="a-16071" test="not(cda:targetSiteCode) or cda:targetSiteCode[@code]">The targetSiteCode, if present, SHALL contain exactly one [1..1] @code, which SHALL be selected from ValueSet Body Site Value Set 2.16.840.1.113883.3.88.12.3221.8.9 DYNAMIC (CONF:16071).</sch:assert>
      <sch:assert id="a-19198" test="cda:code[count(cda:originalText) &lt; 2]">This code SHOULD contain zero or one [0..1] originalText (CONF:19198).</sch:assert>
      <sch:assert id="a-19199" test="not(cda:code/cda:originalText) or cda:code/cda:originalText[count(cda:reference) &lt; 2]">The originalText, if present, SHOULD contain zero or one [0..1] reference (CONF:19199).</sch:assert>
      <sch:assert id="a-19200" test="not(cda:code/cda:originalText/cda:reference) or cda:code/cda:originalText/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:19200).</sch:assert>
      <sch:assert id="a-19202" test="count(cda:code[@codeSystem])=0 or cda:code[@codeSystem='2.16.840.1.113883.6.1'] or cda:code[@codeSystem='2.16.840.1.113883.6.96'] or cda:code[@codeSystem='2.16.840.1.113883.6.12'] or cda:code[@codeSystem='2.16.840.1.113883.6.4']">This @code SHOULD be selected from LOINC (CodeSystem: 2.16.840.1.113883.6.1) or SNOMED CT (CodeSystem: 2.16.840.1.113883.6.96), and MAY be selected from CPT-4 (CodeSystem: 2.16.840.1.113883.6.12), ICD9 Procedures (CodeSystem: 2.16.840.1.113883.6.4) (CONF:19202).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.13-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.13']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.13-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.59-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.59-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.13-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.59-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.59']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.59-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.60-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.60-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.60-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.60']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.60-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.58-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.58-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.58-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.58']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.58-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.57-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.57-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-warnings-abstract" />
      <sch:assert id="a-16700" test="count(cda:value[@xsi-type='PQ'])=0 or count(cda:value[@xsi-type='PQ'])=1">If xsi:type=PQ, then @units shall be drawn from Unified Code for Units of Measure (UCUM) 2.16.840.1.113883.6.8 code system. Additional constraint is dependent on criteria in the corresponding eMeasure (CONF:16700).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.57-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.57']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.57-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.26-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.26-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.13-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.26-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.26']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.26-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.25-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.25-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.25-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.25']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.25-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.17.2.4-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.4-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.4-warnings" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.4']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.2.4-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.2.1-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.1-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.2.4-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.1-warnings" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.1-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.2.2-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.2-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.2-warnings" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.2-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.2.3-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.3-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.2-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.3-warnings" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.3']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.3-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.98-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.98-warnings-abstract" abstract="true">
      <sch:assert id="a-12997" test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:text) &lt; 2]">This externalDocument SHOULD contain zero or one [0..1] text (CONF:12997).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.98-warnings" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.98-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.97-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.97-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.98-warnings-abstract" />
      <sch:assert id="a-12864" test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:code[@code='57024-2'][@codeSystem='2.16.840.1.113883.6.1']) &lt; 2]">This externalDocument SHOULD contain zero or one [0..1] code="57024-2" Health Quality Measure Document (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:12864).</sch:assert>
      <sch:assert id="a-12865" test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:text) &lt; 2]">This externalDocument SHOULD contain zero or one [0..1] text (CONF:12865).</sch:assert>
      <sch:assert id="a-12867" test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:setId) &lt; 2]">This externalDocument SHOULD contain zero or one [0..1] setId (CONF:12867).</sch:assert>
      <sch:assert id="a-12869" test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:versionNumber) &lt; 2]">This externalDocument SHOULD contain zero or one [0..1] versionNumber (CONF:12869).</sch:assert>
      <sch:assert id="a-16692" test="count(cda:component)=0 or count(cda:component/cda:observation/cda:referenceRange) = 1">The referenceRange is used to indicate the probability that the patient would meet the corresponding population criteria. It is relevant for outcome measures, where predictive models allow for calculating the probability that a patient would meet the criteria of a given population (CONF:16692).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.97-warnings" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.97']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.97-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.27-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.27-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.27-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.27']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.27-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.67-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.67-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-warnings-abstract" />
      <sch:assert id="a-13926" test="count(cda:text) &lt; 2">SHOULD contain zero or one [0..1] text (CONF:13926).</sch:assert>
      <sch:assert id="a-13927" test="not(cda:text) or cda:text[count(cda:reference) &lt; 2]">The text, if present, SHOULD contain zero or one [0..1] reference (CONF:13927).</sch:assert>
      <sch:assert id="a-13933" test="not(cda:interpretationCode) or cda:interpretationCode">SHOULD contain zero or more [0..*] interpretationCode (CONF:13933).</sch:assert>
      <sch:assert id="a-13937" test="not(cda:referenceRange) or cda:referenceRange">SHOULD contain zero or more [0..*] referenceRange (CONF:13937).</sch:assert>
      <sch:assert id="a-13938" test="not(cda:referenceRange) or cda:referenceRange[count(cda:observationRange)=1]">The referenceRange, if present, SHALL contain exactly one [1..1] observationRange (CONF:13938).</sch:assert>
      <sch:assert id="a-19337" test="count(cda:code[@codeSystem='2.16.840.1.113883.6.1'])=1">@code SHOULD be selected from CodeSystem LOINC (2.16.840.1.113883.6.1) (CONF:19337).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.67-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.67']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.67-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.28-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.28-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.67-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.28-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.28']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.28-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.77-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.77-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.4-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.77-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.77']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.77-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.1.1-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.1.1-warnings-abstract" abstract="true">
      <sch:assert id="a-5303" test="cda:recordTarget/cda:patientRole/cda:patient[count(cda:maritalStatusCode) &lt; 2]">This patient SHOULD contain zero or one [0..1] maritalStatusCode, which SHALL be selected from ValueSet HL7 MaritalStatus 2.16.840.1.113883.1.11.12212 DYNAMIC (CONF:5303).</sch:assert>
      <sch:assert id="a-5326" test="not(cda:recordTarget/cda:patientRole/cda:patient/cda:guardian) or cda:recordTarget/cda:patientRole/cda:patient/cda:guardian[count(cda:code) &lt; 2]">The guardian, if present, SHOULD contain zero or one [0..1] code, which SHALL be selected from ValueSet Personal Relationship Role Type 2.16.840.1.113883.1.11.19563 DYNAMIC (CONF:5326).</sch:assert>
      <sch:assert id="a-5359" test="not(cda:recordTarget/cda:patientRole/cda:patient/cda:guardian) or cda:recordTarget/cda:patientRole/cda:patient/cda:guardian[not(cda:addr) or cda:addr]">The guardian, if present, SHOULD contain zero or more [0..*] addr (CONF:5359).</sch:assert>
      <sch:assert id="a-5375" test="cda:recordTarget/cda:patientRole/cda:telecom[@use]">Such telecoms SHOULD contain exactly one [1..1] @use, which SHALL be selected from ValueSet Telecom Use (US Realm Header) 2.16.840.1.113883.11.20.9.20 DYNAMIC (CONF:5375).</sch:assert>


      <sch:assert id="a-5404" test="not(cda:recordTarget/cda:patientRole/cda:patient/cda:birthplace/cda:place/cda:addr) or cda:recordTarget/cda:patientRole/cda:patient/cda:birthplace/cda:place/cda:addr[count(cda:country[@xsi:type='ST']) &lt; 2]">This addr SHOULD contain zero or one [0..1] country, where the @code SHALL be selected from ValueSet CountryValueSet 2.16.840.1.113883.3.88.12.80.63 DYNAMIC (CONF:5404).</sch:assert>


      <sch:assert id="a-5406" test="cda:recordTarget/cda:patientRole/cda:patient[not(cda:languageCommunication) or cda:languageCommunication]">This patient SHOULD contain zero or more [0..*] languageCommunication (CONF:5406).</sch:assert>
      <sch:assert id="a-5430" test="count(cda:author/cda:assignedAuthor/cda:assignedPerson)=1 or count(cda:author/cda:assignedAuthor/cda:assignedAuthoringDevice)=1">This assignedAuthor SHALL contain exactly one  [1..1] assignedPerson or assignedAuthoringDevice (CONF:5430).</sch:assert>
      <sch:assert id="a-5579" test="count(cda:legalAuthenticator) &lt; 2">SHOULD contain zero or one [0..1] legalAuthenticator (CONF:5579).</sch:assert>
      <sch:assert id="a-5580" test="not(cda:legalAuthenticator) or cda:legalAuthenticator[count(cda:time)=1]">The legalAuthenticator, if present, SHALL contain exactly one [1..1] time (CONF:5580).</sch:assert>
      <sch:assert id="a-5583" test="not(cda:legalAuthenticator) or cda:legalAuthenticator[count(cda:signatureCode)=1]">The legalAuthenticator, if present, SHALL contain exactly one [1..1] signatureCode (CONF:5583).</sch:assert>
      <sch:assert id="a-5584" test="not(cda:legalAuthenticator/cda:signatureCode) or cda:legalAuthenticator/cda:signatureCode[@code='S']">This signatureCode SHALL contain exactly one [1..1] @code="S" (CodeSystem: Participationsignature 2.16.840.1.113883.5.89 STATIC) (CONF:5584).</sch:assert>
      <sch:assert id="a-5585" test="not(cda:legalAuthenticator) or cda:legalAuthenticator[count(cda:assignedEntity)=1]">The legalAuthenticator, if present, SHALL contain exactly one [1..1] assignedEntity (CONF:5585).</sch:assert>
      <sch:assert id="a-5586" test="not(cda:legalAuthenticator/cda:assignedEntity) or cda:legalAuthenticator/cda:assignedEntity[count(cda:id) &gt; 0]">This assignedEntity SHALL contain at least one [1..*] id (CONF:5586).</sch:assert>
      <sch:assert id="a-5589" test="not(cda:legalAuthenticator/cda:assignedEntity) or cda:legalAuthenticator/cda:assignedEntity[count(cda:addr) &gt; 0]">This assignedEntity SHALL contain at least one [1..*] addr (CONF:5589).</sch:assert>
      <sch:assert id="a-5595" test="not(cda:legalAuthenticator/cda:assignedEntity) or cda:legalAuthenticator/cda:assignedEntity[count(cda:telecom) &gt; 0]">This assignedEntity SHALL contain at least one [1..*] telecom (CONF:5595).</sch:assert>
      <sch:assert id="a-5597" test="not(cda:legalAuthenticator/cda:assignedEntity) or cda:legalAuthenticator/cda:assignedEntity[count(cda:assignedPerson)=1]">This assignedEntity SHALL contain exactly one [1..1] assignedPerson (CONF:5597).</sch:assert>
      <sch:assert id="a-5598" test="not(cda:legalAuthenticator/cda:assignedEntity/cda:assignedPerson) or cda:legalAuthenticator/cda:assignedEntity/cda:assignedPerson[count(cda:name) &gt; 0]">This assignedPerson SHALL contain at least one [1..*] name (CONF:5598).</sch:assert>
      <sch:assert id="a-7993" test="not(cda:recordTarget/cda:patientRole/cda:patient/cda:guardian/cda:telecom) or cda:recordTarget/cda:patientRole/cda:patient/cda:guardian/cda:telecom[@use]">The telecom, if present, SHOULD contain exactly one [1..1] @use, which SHALL be selected from ValueSet Telecom Use (US Realm Header) 2.16.840.1.113883.11.20.9.20 DYNAMIC (CONF:7993).</sch:assert>
      <sch:assert id="a-7994" test="not(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:telecom) or cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:telecom[@use]">Such telecoms SHOULD contain exactly one [1..1] @use, which SHALL be selected from ValueSet Telecom Use (US Realm Header) 2.16.840.1.113883.11.20.9.20 DYNAMIC (CONF:7994).</sch:assert>
      <sch:assert id="a-7995" test="cda:author/cda:assignedAuthor/cda:telecom[@use]">Such telecoms SHOULD contain exactly one [1..1] @use, which SHALL be selected from ValueSet Telecom Use (US Realm Header) 2.16.840.1.113883.11.20.9.20 DYNAMIC (CONF:7995).</sch:assert>
      <sch:assert id="a-7996" test="not(cda:dataEnterer/cda:assignedEntity/cda:telecom) or cda:dataEnterer/cda:assignedEntity/cda:telecom[@use]">Such telecoms SHOULD contain exactly one [1..1] @use, which SHALL be selected from ValueSet Telecom Use (US Realm Header) 2.16.840.1.113883.11.20.9.20 DYNAMIC (CONF:7996).</sch:assert>
      <sch:assert id="a-7998" test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:telecom[@use]">This telecom SHOULD contain exactly one [1..1] @use, which SHALL be selected from ValueSet Telecom Use (US Realm Header) 2.16.840.1.113883.11.20.9.20 DYNAMIC (CONF:7998).</sch:assert>
      <sch:assert id="a-7999" test="not(cda:legalAuthenticator/cda:assignedEntity/cda:telecom) or cda:legalAuthenticator/cda:assignedEntity/cda:telecom[@use]">Such telecoms SHOULD contain exactly one [1..1] @use, which SHALL be selected from ValueSet Telecom Use (US Realm Header) 2.16.840.1.113883.11.20.9.20 DYNAMIC (CONF:7999).</sch:assert>
      <sch:assert id="a-8000" test="not(cda:authenticator/cda:assignedEntity/cda:telecom) or cda:authenticator/cda:assignedEntity/cda:telecom[@use]">Such telecoms SHOULD contain exactly one [1..1] @use, which SHALL be selected from ValueSet Telecom Use (US Realm Header) 2.16.840.1.113883.11.20.9.20 DYNAMIC (CONF:8000).</sch:assert>
      <sch:assert id="a-8220" test="not(informant) or informant/cda:*/addr">This assignedEntity SHOULD contain at least one [1..*] addr (CONF:8220).</sch:assert>
      <sch:assert id="a-9945" test="not(cda:informant/cda:assignedEntity) or cda:informant/cda:assignedEntity[cda:id]">This assignedEntity SHOULD contain zero or more [0..*] id (CONF:9945).</sch:assert>
      <sch:assert id="a-9965" test="not(cda:recordTarget/cda:patientRole/cda:patient/cda:languageCommunication) or cda:recordTarget/cda:patientRole/cda:patient/cda:languageCommunication[count(cda:proficiencyLevelCode) &lt; 2]">The languageCommunication, if present, SHOULD contain zero or one [0..1] proficiencyLevelCode, which SHALL be selected from ValueSet LanguageAbilityProficiency 2.16.840.1.113883.1.11.12199 DYNAMIC (CONF:9965).</sch:assert>
      <sch:assert id="a-14839" test="not(cda:documentationOf/cda:serviceEvent) or cda:documentationOf/cda:serviceEvent[not(cda:performer) or cda:performer]">This serviceEvent SHOULD contain zero or more [0..*] performer (CONF:14839).</sch:assert>
      <sch:assert id="a-14842" test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity) or cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity[count(cda:code) &lt; 2]">This assignedEntity SHOULD contain zero or one [0..1] code (CONF:14842).</sch:assert>
      <sch:assert id="a-14847" test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:id) or cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:id[not(@root='2.16.840.1.113883.4.6') or @root='2.16.840.1.113883.4.6']">Such ids SHOULD contain zero or one [0..1] @root="2.16.840.1.113883.4.6" National Provider Identifier (CONF:14847).</sch:assert>
      <sch:assert id="a-16783" test="cda:author/cda:assignedAuthor[count(cda:assignedAuthoringDevice) &lt; 2]">This assignedAuthor SHOULD contain zero or one [0..1] assignedAuthoringDevice (CONF:16783).</sch:assert>
      <sch:assert id="a-16787" test="cda:author/cda:assignedAuthor[count(cda:code) &lt; 2]">This assignedAuthor SHOULD contain zero or one [0..1] code (CONF:16787).</sch:assert>
      <sch:assert id="a-16788" test="not(cda:author/cda:assignedAuthor/cda:code) or cda:author/cda:assignedAuthor/cda:code[@code]">The code, if present, SHOULD contain exactly one [1..1] @code, which SHOULD be selected from ValueSet Healthcare Provider Taxonomy (NUCC - HIPAA) 2.16.840.1.114222.4.11.1066 DYNAMIC (CONF:16788).</sch:assert>
      <sch:assert id="a-16819" test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:functionCode) or cda:documentationOf/cda:serviceEvent/cda:performer/cda:functionCode[not(@codeSystem) or @codeSystem]">The functionCode, if present, SHOULD contain zero or one [0..1] @codeSystem, which SHOULD be selected from CodeSystem participationFunction (2.16.840.1.113883.5.88) STATIC (CONF:16819).</sch:assert>
      <sch:assert id="a-16820" test="not(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:id) or cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:id[not(@root='2.16.840.1.113883.4.6') or @root='2.16.840.1.113883.4.6']">Such ids SHOULD contain zero or one [0..1] @root="2.16.840.1.113883.4.6" National Provider Identifier (CONF:16820).</sch:assert>
      <sch:assert id="a-16821" test="not(cda:dataEnterer/cda:assignedEntity/cda:id) or cda:dataEnterer/cda:assignedEntity/cda:id[not(@root='2.16.840.1.113883.4.6') or @root='2.16.840.1.113883.4.6']">Such ids SHOULD contain zero or one [0..1] @root="2.16.840.1.113883.4.6" National Provider Identifier (CONF:16821).</sch:assert>
      <sch:assert id="a-16822" test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:id[not(@root='2.16.840.1.113883.4.6') or @root='2.16.840.1.113883.4.6']">Such ids SHOULD contain zero or one [0..1] @root="2.16.840.1.113883.4.6" National Provider Identifier (CONF:16822).</sch:assert>
      <sch:assert id="a-16824" test="not(cda:authenticator/cda:assignedEntity/cda:id) or cda:authenticator/cda:assignedEntity/cda:id[not(@root='2.16.840.1.113883.4.6') or @root='2.16.840.1.113883.4.6']">Such ids SHOULD contain zero or one [0..1] @root="2.16.840.1.113883.4.6" National Provider Identifier  (CONF:16824).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.1.1-warnings" context="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.22.1.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.1.1-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.1.1-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.1.1-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.1.1-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.1.1-warnings" context="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.24.1.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.1.1-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.18-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.18-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.13-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.18-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.18']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.18-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.1.2-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.1.2-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.1.1-warnings-abstract" />
      <sch:assert id="a-16588" test="count(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity[count(cda:id[@root='2.16.840.1.113883.4.6'])=1]) &lt; 2">This assignedEntity id/@root coupled with the id/@extension represents the individual provider's National Provider Identification number (NPI).
This assignedEntity SHALL contain exactly one [1..1] id (CONF:16587) such that it SHOULD contain zero or one [0..1] @root="2.16.840.1.113883.4.6" National Provider ID (CONF:16588).</sch:assert>
      <sch:assert id="a-16706" test="count(cda:informationRecipient) = 0 or count(cda:informationRecipient/cda:intendedRecipient/cda:id) &gt; 0">IntendedRecipient ID can be used by the receiver to ensure they are processing a file that was intended to be sent to them (CONF:16706).</sch:assert>
      <sch:assert id="a-16858" test="cda:recordTarget/cda:patientRole[count(cda:id[@root='2.16.840.1.113883.4.572'])&lt;=1]">This patientRole SHALL contain exactly one [1..1] id (CONF:16857) such that it SHOULD contain zero or one [0..1] @root="2.16.840.1.113883.4.572" Medicare HIC number (CONF:16858).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.1.2-warnings" context="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.24.1.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.1.2-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.81-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.81-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.81-warnings" context="cda:Participant2[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.81']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.81-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.100-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.100-warnings-abstract" abstract="true">
      <sch:assert id="a-13379" test="cda:participantRole[not(cda:addr) or cda:addr]">This participantRole SHOULD contain zero or more [0..*] addr (CONF:13379).</sch:assert>
      <sch:assert id="a-13380" test="cda:participantRole[not(cda:telecom) or cda:telecom]">This participantRole SHOULD contain zero or more [0..*] telecom (CONF:13380).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.100-warnings" context="cda:Participant2[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.100']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.100-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.19-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.19-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.19-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.19']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.19-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.17-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.17-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.44-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.17-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.17']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.17-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.29-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.29-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-warnings-abstract" />
      <sch:assert id="a-13548" test="cda:effectiveTime[count(cda:high) &lt; 2]">This effectiveTime SHOULD contain zero or one [0..1] high (CONF:13548).</sch:assert>
      <sch:assert id="a-13556" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:13553) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:13554). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:13555). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:13556).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.29-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.29']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.29-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.12-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.12-warnings-abstract" abstract="true">
      <sch:assert id="a-8299" test="count(cda:effectiveTime) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:8299).</sch:assert>
      <sch:assert id="a-8301" test="not(cda:performer) or cda:performer">SHOULD contain zero or more [0..*] performer (CONF:8301).</sch:assert>
      <sch:assert id="a-8302" test="not(cda:performer) or cda:performer[count(cda:assignedEntity)=1]">The performer, if present, SHALL contain exactly one [1..1] assignedEntity (CONF:8302).</sch:assert>
      <sch:assert id="a-8303" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:id) &gt; 0]">This assignedEntity SHALL contain at least one [1..*] id (CONF:8303).</sch:assert>
      <sch:assert id="a-8304" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:addr)=1]">This assignedEntity SHALL contain exactly one [1..1] addr (CONF:8304).</sch:assert>
      <sch:assert id="a-8305" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:telecom)=1]">This assignedEntity SHALL contain exactly one [1..1] telecom (CONF:8305).</sch:assert>
      <sch:assert id="a-8306" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:representedOrganization) &lt; 2]">This assignedEntity SHOULD contain zero or one [0..1] representedOrganization (CONF:8306).</sch:assert>
      <sch:assert id="a-8307" test="not(cda:performer/cda:assignedEntity/cda:representedOrganization) or cda:performer/cda:assignedEntity/cda:representedOrganization[not(cda:id) or cda:id]">The representedOrganization, if present, SHOULD contain zero or more [0..*] id (CONF:8307).</sch:assert>
      <sch:assert id="a-8309" test="not(cda:performer/cda:assignedEntity/cda:representedOrganization) or cda:performer/cda:assignedEntity/cda:representedOrganization[count(cda:addr)=1]">The representedOrganization, if present, SHALL contain exactly one [1..1] addr (CONF:8309).</sch:assert>
      <sch:assert id="a-8310" test="not(cda:performer/cda:assignedEntity/cda:representedOrganization) or cda:performer/cda:assignedEntity/cda:representedOrganization[count(cda:telecom)=1]">The representedOrganization, if present, SHALL contain exactly one [1..1] telecom (CONF:8310).</sch:assert>
      <sch:assert id="a-19186" test="cda:code[count(cda:originalText) &lt; 2]">This code SHOULD contain zero or one [0..1] originalText (CONF:19186).</sch:assert>
      <sch:assert id="a-19190" test="count(cda:code[@codeSystem])=0 or cda:code[@codeSystem='2.16.840.1.113883.6.1'] or cda:code[@codeSystem='2.16.840.1.113883.6.96'] or cda:code[@codeSystem='2.16.840.1.113883.6.104']">This code in a procedure activity observation SHOULD be selected from LOINC (CodeSystem: 2.16.840.1.113883.6.1) or SNOMED CT (CodeSystem: 2.16.840.1.113883.6.96) (CONF:19190).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.12-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.12']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.12-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.32-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.32-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.12-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.32-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.32']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.32-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.30-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.30-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-warnings-abstract" />
      <sch:assert id="a-13668" test="cda:effectiveTime[count(cda:high) &lt; 2]">This effectiveTime SHOULD contain zero or one [0..1] high (CONF:13668).</sch:assert>
      <sch:assert id="a-13672" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:13669) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:13670). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:13671). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:13672).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.30-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.30']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.30-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.34-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.34-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.12-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.34-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.34']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.34-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.39-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.39-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.39-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.39']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.39-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.31-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.31-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.39-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.31-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.31']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.31-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.75-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.75-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.42-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.75-warnings" context="cda:substanceAdministration[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.75']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.75-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.33-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.33-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.39-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.33-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.33']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.33-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.20-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.20-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.2-warnings-abstract" />
      <sch:assert id="a-16696" test="count(cda:value[@xsi-type='PQ'])=0 or count(cda:value[@xsi-type='PQ'])=1">If xsi:type=PQ, then @units shall be drawn from Unified Code for Units of Measure (UCUM) 2.16.840.1.113883.6.8 code system. Additional constraint is dependent on criteria in the corresponding eMeasure (CONF:16696).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.20-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.20']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.20-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.99-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.99-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.43-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.99-warnings" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.99']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.99-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.18-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.18-warnings-abstract" abstract="true">
      <sch:assert id="a-7456" test="count(cda:effectiveTime) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:7456).</sch:assert>
      <sch:assert id="a-7457" test="count(cda:repeatNumber[@xsi:type='IVL&lt;INT&gt;']) &lt; 2">SHOULD contain zero or one [0..1] repeatNumber (CONF:7457).</sch:assert>
      <sch:assert id="a-7458" test="count(cda:quantity) &lt; 2">SHOULD contain zero or one [0..1] quantity (CONF:7458).</sch:assert>
      <sch:assert id="a-7468" test="not(cda:performer/cda:assignedEntity) or cda:performer/cda:assignedEntity[count(cda:addr) &lt; 2]">This assignedEntity SHOULD contain zero or one [0..1] addr (CONF:7468).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.18-warnings" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.18']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.18-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.45-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.45-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.18-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.45-warnings" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.45']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.45-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.36-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.36-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-warnings-abstract" />
      <sch:assert id="a-13972" test="cda:effectiveTime[count(cda:high) &lt; 2]">This effectiveTime SHOULD contain zero or one [0..1] high (CONF:13972).</sch:assert>
      <sch:assert id="a-13980" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:13977) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:13978). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:13979). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:13980).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.36-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.36']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.36-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.35-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.35-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.104-warnings-abstract" />
      <sch:assert id="a-14071" test="cda:effectiveTime[count(cda:high) &lt; 2]">This effectiveTime SHOULD contain zero or one [0..1] high (CONF:14071).</sch:assert>
      <sch:assert id="a-14079" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:14076) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:14077). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:14078). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:14079).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.35-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.35']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.35-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.7-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.7-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.90-warnings-abstract" />
      <sch:assert id="a-7404" test="count(cda:participant[@typeCode='CSM'][count(cda:participantRole)=1]) &lt; 2">SHOULD contain zero or one [0..1] participant (CONF:7402) such that it SHALL contain exactly one [1..1] @typeCode="CSM" Consumable (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:7403). SHALL contain exactly one [1..1] participantRole (CONF:7404).</sch:assert>
      <sch:assert id="a-7405" test="not(cda:participant[@typeCode='CSM']/cda:participantRole) or cda:participant[@typeCode='CSM']/cda:participantRole[@classCode='MANU']">This participantRole SHALL contain exactly one [1..1] @classCode="MANU" Manufactured Product (CodeSystem: RoleClass 2.16.840.1.113883.5.110 STATIC) (CONF:7405).</sch:assert>
      <sch:assert id="a-7406" test="not(cda:participant[@typeCode='CSM']/cda:participantRole) or cda:participant[@typeCode='CSM']/cda:participantRole[count(cda:playingEntity)=1]">This participantRole SHALL contain exactly one [1..1] playingEntity (CONF:7406).</sch:assert>
      <sch:assert id="a-7407" test="not(cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity) or cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity[@classCode='MMAT']">This playingEntity SHALL contain exactly one [1..1] @classCode="MMAT" Manufactured Material (CodeSystem: EntityClass 2.16.840.1.113883.5.41 STATIC) (CONF:7407).</sch:assert>
      <sch:assert id="a-7419" test="not(cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity) or cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity[count(cda:code)=1]">This playingEntity SHALL contain exactly one [1..1] code (CONF:7419).</sch:assert>
      <sch:assert id="a-7422" test="cda:value[@xsi:type='CD'][count(cda:originalText) &lt; 2]">This value SHOULD contain zero or one [0..1] originalText (CONF:7422).</sch:assert>
      <sch:assert id="a-7424" test="not(cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity/cda:code) or cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity/cda:code[count(cda:originalText) &lt; 2]">This code SHOULD contain zero or one [0..1] originalText (CONF:7424).</sch:assert>
      <sch:assert id="a-7425" test="not(cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity/cda:code/cda:originalText) or cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity/cda:code/cda:originalText[count(cda:reference) &lt; 2]">The originalText, if present, SHOULD contain zero or one [0..1] reference (CONF:7425).</sch:assert>
      <sch:assert id="a-15950" test="not(cda:value[@xsi:type='CD']/cda:originalText/cda:reference) or cda:value[@xsi:type='CD']/cda:originalText/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:15950).</sch:assert>
      <sch:assert id="a-15952" test="not(cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity/cda:code/cda:originalText/cda:reference) or cda:participant[@typeCode='CSM']/cda:participantRole/cda:playingEntity/cda:code/cda:originalText/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:15952).</sch:assert>
      <sch:assert id="a-15955" test="not(cda:entryRelationship[@inversionInd='true'][@typeCode='MFST'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.9'])=1]) or cda:entryRelationship[@inversionInd='true'][@typeCode='MFST'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.9'])=1]">SHOULD contain zero or more [0..*] entryRelationship (CONF:7447) such that it SHALL contain exactly one [1..1] @inversionInd="true" True (CONF:7449). SHALL contain exactly one [1..1] @typeCode="MFST" Is Manifestation of (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:7907). SHALL contain exactly one [1..1] Reaction Observation (templateId:2.16.840.1.113883.10.20.22.4.9) (CONF:15955).</sch:assert>
      <sch:assert id="a-15956" test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.8'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:9961) such that it SHALL contain exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:9962). SHALL contain exactly one [1..1] @inversionInd="true" True (CONF:9964). SHALL contain exactly one [1..1] Severity Observation (templateId:2.16.840.1.113883.10.20.22.4.8) (CONF:15956).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.7-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.7']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.7-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.46-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.46-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.7-warnings-abstract" />
      <sch:assert id="a-14109" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:14106) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CONF:14107). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:14108). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:14109).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.46-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.46']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.46-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.43-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.43-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.7-warnings-abstract" />
      <sch:assert id="a-14133" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:14130) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CONF:14131). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:14132). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:14133).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.43-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.43']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.43-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.44-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.44-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.7-warnings-abstract" />
      <sch:assert id="a-14158" test="count(cda:entryRelationship[@typeCode='MFST'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.85'])=1]) &lt; 2">SHOULD contain zero or one [0..1] entryRelationship (CONF:14155) such that it SHALL contain exactly one [1..1] @typeCode="MFST" (CONF:14156). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:14157). SHALL contain exactly one [1..1] Reaction (templateId:2.16.840.1.113883.10.20.24.3.85) (CONF:14158).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.44-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.44']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.44-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.45-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.45-warnings-abstract" abstract="true">
      <sch:assert id="a-8605" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.22.4.46'])&gt;=0">Such components SHOULD contain zero or more [0..*] Family History Observation (templateId:2.16.840.1.113883.10.20.22.4.46) (CONF:8605).</sch:assert>
      <sch:assert id="a-8613" test="cda:subject/cda:relatedSubject[count(cda:subject) &lt; 2]">This relatedSubject SHOULD contain zero or one [0..1] subject (CONF:8613).</sch:assert>
      <sch:assert id="a-8615" test="not(cda:subject/cda:relatedSubject/cda:subject) or cda:subject/cda:relatedSubject/cda:subject[count(cda:birthTime[@xsi:type='TS']) &lt; 2]">The subject, if present, SHOULD contain zero or one [0..1] birthTime (CONF:8615).</sch:assert>
      <sch:assert id="a-15248" test="cda:subject/cda:relatedSubject[count(cda:subject) &lt; 2]">This relatedSubject SHOULD contain zero or one [0..1] subject (CONF:15248).</sch:assert>
      <sch:assert id="a-15976" test="not(cda:subject/cda:relatedSubject/cda:subject) or cda:subject/cda:relatedSubject/cda:subject[count(cda:birthTime) &lt; 2]">The subject, if present, SHOULD contain zero or one [0..1] birthTime (CONF:15976).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.45-warnings" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.45']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.45-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.12-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.12-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.45-warnings-abstract" />
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.12-warnings" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.12']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.12-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.102-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.102-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.102-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.102']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.102-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.101-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.101-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.101-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.101']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.101-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.103-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.103-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.103-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.103']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.103-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.105-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.105-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.105-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.105']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.105-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.25-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.25-warnings-abstract" abstract="true">
      <sch:assert id="a-7369" test="count(cda:value[@xsi:type='CD']) &lt; 2">SHOULD contain zero or one [0..1] value with @xsi:type="CD" (CONF:7369).</sch:assert>
      <sch:assert id="a-16854" test="count(cda:code) &lt; 2">SHOULD contain zero or one [0..1] code (CONF:16854).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.25-warnings" context="cda:criterion[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.25']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.25-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.20-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.20-warnings-abstract" abstract="true">
      <sch:assert id="a-7395" test="count(cda:text) &lt; 2">SHOULD contain zero or one [0..1] text (CONF:7395).</sch:assert>
      <sch:assert id="a-15577" test="not(cda:text) or cda:text[count(cda:reference)=1]">The text, if present, SHOULD contain exactly one [1..1] reference (CONF:15577).</sch:assert>
      <sch:assert id="a-15578" test="not(cda:text/cda:reference) or cda:text/cda:reference[@value]">This reference SHOULD contain exactly one [1..1] @value (CONF:15578).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.20-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.20']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.20-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.23-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.23-warnings-abstract" abstract="true">
      <sch:assert id="a-7413" test="cda:manufacturedMaterial/cda:code[count(cda:originalText) &lt; 2]">This code SHOULD contain zero or one [0..1] originalText (CONF:7413).</sch:assert>
      <sch:assert id="a-15986" test="not(cda:manufacturedMaterial/cda:code/cda:originalText) or cda:manufacturedMaterial/cda:code/cda:originalText[count(cda:reference) &lt; 2]">The originalText, if present, SHOULD contain zero or one [0..1] reference (CONF:15986).</sch:assert>
      <sch:assert id="a-15987" test="not(cda:manufacturedMaterial/cda:code/cda:originalText/cda:reference) or cda:manufacturedMaterial/cda:code/cda:originalText/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:15987).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.23-warnings" context="cda:manufacturedProduct[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.23']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.23-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.17-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.17-warnings-abstract" abstract="true">
      <sch:assert id="a-7434" test="count(cda:repeatNumber[@xsi:type='IVL&lt;INT&gt;']) &lt; 2">SHOULD contain zero or one [0..1] repeatNumber (CONF:7434).</sch:assert>
      <sch:assert id="a-7436" test="count(cda:quantity) &lt; 2">SHOULD contain zero or one [0..1] quantity (CONF:7436).</sch:assert>
      <sch:assert id="a-15144" test="count(cda:effectiveTime[@xsi:type='IVL_TS'][@xsi:type='IVL_TS'][count(cda:high)=1]) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:15143) such that it SHALL contain exactly one [1..1] high (CONF:15144).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.17-warnings" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.17']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.17-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.54-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.54-warnings-abstract" abstract="true">
      <sch:assert id="a-9008" test="cda:manufacturedMaterial/cda:code[count(cda:originalText) &lt; 2]">This code SHOULD contain zero or one [0..1] originalText (CONF:9008).</sch:assert>
      <sch:assert id="a-9012" test="count(cda:manufacturerOrganization) &lt; 2">SHOULD contain zero or one [0..1] manufacturerOrganization (CONF:9012).</sch:assert>
      <sch:assert id="a-9014" test="cda:manufacturedMaterial[count(cda:lotNumberText) &lt; 2]">This manufacturedMaterial SHOULD contain zero or one [0..1] lotNumberText (CONF:9014).</sch:assert>
      <sch:assert id="a-15555" test="not(cda:manufacturedMaterial/cda:code/cda:originalText) or cda:manufacturedMaterial/cda:code/cda:originalText[count(cda:reference) &lt; 2]">The originalText, if present, SHOULD contain zero or one [0..1] reference (CONF:15555).</sch:assert>
      <sch:assert id="a-15556" test="not(cda:manufacturedMaterial/cda:code/cda:originalText/cda:reference) or cda:manufacturedMaterial/cda:code/cda:originalText/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:15556).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.54-warnings" context="cda:manufacturedProduct[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.54']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.54-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.19-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.19-warnings-abstract" abstract="true">
      <sch:assert id="a-7488" test="count(cda:effectiveTime) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:7488).</sch:assert>
      <sch:assert id="a-7489" test="count(cda:value[@xsi:type='CD']) &lt; 2">SHOULD contain zero or one [0..1] value with @xsi:type="CD" (CONF:7489).</sch:assert>
      <sch:assert id="a-15985" test="not(cda:value) or cda:value[not(@code) or @code]">The value, if present, SHOULD contain zero or one [0..1] @code (ValueSet: Problem 2.16.840.1.113883.3.88.12.3221.7.4 DYNAMIC) (CONF:15985).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.19-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.19']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.19-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.24-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.24-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.24-warnings" context="cda:participantRole[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.24']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.24-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.8-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.8-warnings-abstract" abstract="true">
      <sch:assert id="a-7350" test="count(cda:text) &lt; 2">SHOULD contain zero or one [0..1] text (CONF:7350).</sch:assert>
      <sch:assert id="a-9117" test="not(cda:interpretationCode) or cda:interpretationCode">SHOULD contain zero or more [0..*] interpretationCode (CONF:9117).</sch:assert>
      <sch:assert id="a-15928" test="not(cda:text) or cda:text[count(cda:reference) &lt; 2]">The text, if present, SHOULD contain zero or one [0..1] reference (CONF:15928).</sch:assert>
      <sch:assert id="a-15929" test="not(cda:text/cda:reference) or cda:text/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:15929).</sch:assert>
      <sch:assert id="a-16038" test="not(cda:interpretationCode) or cda:interpretationCode[not(@code) or @code]">The interpretationCode, if present, SHOULD contain zero or one [0..1] @code, which SHOULD be selected from ValueSet Observation Interpretation (HL7) 2.16.840.1.113883.1.11.78 DYNAMIC (CONF:16038).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.8-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.8']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.8-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.32-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.32-warnings-abstract" abstract="true">
      <sch:assert id="a-7760" test="not(cda:addr) or cda:addr">SHOULD contain zero or more [0..*] addr (CONF:7760).</sch:assert>
      <sch:assert id="a-7761" test="not(cda:telecom) or cda:telecom">SHOULD contain zero or more [0..*] telecom (CONF:7761).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.32-warnings" context="cda:participantRole[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.32']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.32-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.37-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.37-warnings-abstract" abstract="true">
      <sch:assert id="a-16837" test="cda:playingDevice[count(cda:code) &lt; 2]">This playingDevice SHOULD contain zero or one [0..1] code (CONF:16837).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.37-warnings" context="cda:participantRole[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.37']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.37-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.80-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.80-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.80-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.80 ']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.80-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.31-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.31-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.31-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.31']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.31-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.5-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.5-warnings-abstract" abstract="true">
      <sch:assert id="a-9270" test="count(cda:text) &lt; 2">SHOULD contain zero or one [0..1] text (CONF:9270).</sch:assert>
      <sch:assert id="a-15529" test="not(cda:text) or cda:text[count(cda:reference) &lt; 2]">The text, if present, SHOULD contain zero or one [0..1] reference (CONF:15529).</sch:assert>
      <sch:assert id="a-15530" test="not(cda:text/cda:reference) or cda:text/cda:reference[not(@value) or @value]">The reference, if present, SHOULD contain zero or one [0..1] @value (CONF:15530).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.5-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.5']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.5-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.28-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.28-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.28-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.28']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.28-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.86-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.86-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.86-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.86']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.86-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.85-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.85-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.85-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.85']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.85-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.50-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.50-warnings-abstract" abstract="true">
      <sch:assert id="a-8751" test="count(cda:quantity) &lt; 2">SHOULD contain zero or one [0..1] quantity (CONF:8751).</sch:assert>
      <sch:assert id="a-15498" test="count(cda:effectiveTime[@xsi:type='IVL_TS']) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:15498).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.50-warnings" context="cda:supply[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.50']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.50-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.72-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.72-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.72-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.72']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.72-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.17.2.1-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.1-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.1-warnings" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.2.1-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.17.3.8-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.17.3.8-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.17.3.8-warnings" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.3.8-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.46-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.46-warnings-abstract" abstract="true">
      <sch:assert id="a-8593" test="count(cda:effectiveTime) &lt; 2">SHOULD contain zero or one [0..1] effectiveTime (CONF:8593).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.46-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.46']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.46-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.4.47-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.47-warnings-abstract" abstract="true">
      <sch:assert test="."></sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.4.47-warnings" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.47']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.4.47-warnings-abstract" />
    </sch:rule>
  </sch:pattern>
</sch:schema>