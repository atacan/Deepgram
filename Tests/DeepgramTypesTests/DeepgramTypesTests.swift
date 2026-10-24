import DeepgramTypes
import Foundation
import Testing

struct DeepgramTypesTests {
    @Test func agentConfigurationRoundTripsWithoutOptionalDates() throws {
        let original = Components.Schemas.AgentConfigurationV1(agent_id: "agent", config: .init())
        let data = try JSONEncoder().encode(original)
        #expect(try JSONDecoder().decode(Components.Schemas.AgentConfigurationV1.self, from: data) == original)
    }
}
