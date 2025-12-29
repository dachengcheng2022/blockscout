defmodule BlockScoutWeb.API.V2.ConfigControllerTest do
  use BlockScoutWeb.ConnCase

  @chain_type Application.compile_env(:explorer, :chain_type)

  describe "/config/backend" do
    test "returns CHAIN_TYPE when configured", %{conn: conn} do
      request = get(conn, "/api/v2/config/backend")
      response = json_response(request, 200)

      assert %{"CHAIN_TYPE" => chain_type} = response
      assert is_binary(chain_type) or is_atom(chain_type)
    end

    test "returns the configured chain type value", %{conn: conn} do
      request = get(conn, "/api/v2/config/backend")
      response = json_response(request, 200)

      assert %{"CHAIN_TYPE" => chain_type} = response

      # Convert to atom for comparison if needed
      chain_type_atom = if is_binary(chain_type), do: String.to_existing_atom(chain_type), else: chain_type
      assert chain_type_atom == @chain_type
    end
  end

  describe "/config/backend-version" do
    test "get json rps url if set", %{conn: conn} do
      version = "v6.3.0-beta"
      Application.put_env(:block_scout_web, :version, version)

      request = get(conn, "/api/v2/config/backend-version")

      assert %{"backend_version" => ^version} = json_response(request, 200)
    end

    test "get nil backend version if not set", %{conn: conn} do
      Application.put_env(:block_scout_web, :version, nil)

      request = get(conn, "/api/v2/config/backend-version")

      assert %{"backend_version" => nil} = json_response(request, 200)
    end
  end

  describe "/config/public-metrics" do
    test "returns configured update period hours", %{conn: conn} do
      # save existing configuration and set test value
      prev = Application.get_env(:explorer, Explorer.Chain.Metrics.PublicMetrics)
      Application.put_env(:explorer, Explorer.Chain.Metrics.PublicMetrics, update_period_hours: 7)

      on_exit(fn -> Application.put_env(:explorer, Explorer.Chain.Metrics.PublicMetrics, prev) end)

      request = get(conn, "/api/v2/config/public-metrics")
      assert %{"update_period_hours" => 7} = json_response(request, 200)
    end
  end

  describe "/config/smart-contracts/languages" do
    @base_languages ["solidity", "vyper", "yul", "geas"]

    case Application.compile_env(:explorer, :chain_type) do
      :arbitrum ->
        test "gets smart-contract languages", %{conn: conn} do
          request = get(conn, "/api/v2/config/smart-contracts/languages")
          response = json_response(request, 200)

          assert response == %{"languages" => @base_languages ++ ["stylus_rust"]}
        end

      :zilliqa ->
        test "gets smart-contract languages", %{conn: conn} do
          request = get(conn, "/api/v2/config/smart-contracts/languages")
          response = json_response(request, 200)

          assert response == %{"languages" => @base_languages ++ ["scilla"]}
        end

      _ ->
        test "gets smart-contract languages", %{conn: conn} do
          request = get(conn, "/api/v2/config/smart-contracts/languages")
          response = json_response(request, 200)

          assert response == %{"languages" => @base_languages}
        end
    end
  end
end
