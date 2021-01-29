let
    Source = (pc as text) => let
        Source = Json.Document(Web.Contents("http://api.postcodes.io/postcodes/" & pc)),
        result = Source[result],
        #"Converted to Table" = Record.ToTable(result),
        #"Filtered Rows" = Table.SelectRows(#"Converted to Table", each ([Name] = "latitude" or [Name] = "longitude" or [Name] = "postcode")),
        #"Pivoted Column" = Table.Pivot(#"Filtered Rows", List.Distinct(#"Filtered Rows"[Name]), "Name", "Value")
    in
        #"Pivoted Column"
in
    Source