import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CssTest.allTests),
        testCase(ElementsTest.allTests),
        testCase(QueryParserTest.allTests),
        testCase(SelectorTest.allTests),
        testCase(AttributeParseTest.allTests),
        testCase(CharacterReaderTest.allTests),
        testCase(HtmlParserTest.allTests),
        testCase(ParseSettingsTest.allTests),
        testCase(TagTest.allTests),
        testCase(TokenQueueTest.allTests),
        testCase(XmlTreeBuilderTest.allTests),
        testCase(FormElementTest.allTests),
        testCase(ElementTest.allTests),
        testCase(EntitiesTest.allTests),
        testCase(DocumentTypeTest.allTests),
        testCase(TextNodeTest.allTests),
        testCase(DocumentTest.allTests),
        testCase(AttributesTest.allTests),
        testCase(NodeTest.allTests),
        testCase(AttributeTest.allTests),
        testCase(CleanerTest.allTests),
        testCase(StringUtilTest.allTests)
    ]
}
#endif
