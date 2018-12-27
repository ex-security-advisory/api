use Amnesia

defdatabase ElixirSecurityAdvisory.Vulnerabilities.Database do
  @moduledoc false

  deftable(Package)

  deftable Revision, [{:id, autoincrement}, :reference], type: :ordered_set, index: [:reference] do
    @moduledoc false

    @type t :: %__MODULE__{id: non_neg_integer, reference: String.t()}
  end

  deftable Vulnerability, [:id, :package_id, :revisions],
    type: :ordered_set,
    index: [:package_id] do
    @moduledoc false

    @type t :: %__MODULE__{
            id: String.t(),
            package_id: String.t(),
            revisions: ElixirSecurityAdvisory.revision()
          }

    def package(%{package_id: package_id}), do: Package.read(package_id)
  end

  deftable Package, [:id, :name],
    type: :ordered_set,
    index: [:name] do
    @moduledoc false

    @type t :: %__MODULE__{id: String.t(), name: String.t()}

    def vulnerabilities(%{id: id}) do
      case Vulnerability.read_at(id, :package_id) do
        nil -> []
        [_ | _] = vulnerabilities -> vulnerabilities
      end
    end
  end
end
