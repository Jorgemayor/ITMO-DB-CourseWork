import React, { useState, useEffect } from 'react'
import axios from 'axios'

const PokemonForm = () => {
  const [pokemonList, setPokemonList] = useState([])
  const [selectedPokemon, setSelectedPokemon] = useState([])
  const [nickname, setNickname] = useState('')
  const [abilityList, setAbilityList] = useState([])
  const [selectedAbility, setSelectedAbility] = useState(0)
  const [natureList, setNatureList] = useState([])
  const [selectedNature, setSelectedNature] = useState(0)
  const [itemList, setItemList] = useState([])
  const [selectedItem, setSelectedItem] = useState(0)
  const [ivs, setIVs] = useState(Array(6).fill(0))
  const [evs, setEVs] = useState(Array(6).fill(0))
  const [isShiny, setIsShiny] = useState(false)

  useEffect(() => {
    // Fetch data for Pokemon list, abilities, natures, and items from the database
    const fetchData = async () => {
      try {
        const pokemonResponse = await axios.get('localhost:3001/api/pokemon')
        setPokemonList(pokemonResponse.data)

        const abilityResponse = await axios.get('localhost:3001/api/ability')
        setAbilityList(abilityResponse.data)

        const natureResponse = await axios.get('localhost:3001/api/nature')
        setNatureList(natureResponse.data)

        const itemResponse = await axios.get('localhost:3001/api/item')
        setItemList(itemResponse.data)
      } catch (error) {
        console.error('Error fetching data:', error)
      }
    }

    fetchData()
  }, [])

  const handlePokemonChange = (e) => {
    setSelectedPokemon(e.target.value)
    // Set additional data about the selected Pokemon based on its name
  }

  const handleAbilityChange = (e) => {
    setSelectedAbility(e.target.value)
  }

  const handleNatureChange = (e) => {
    setSelectedNature(e.target.value)
  }

  const handleItemChange = (e) => {
    setSelectedItem(e.target.value)
  }

  const handleIVChange = (index, value) => {
    const newIVs = [...ivs]
    newIVs[index] = value
    setIVs(newIVs)
  }

  const handleEVChange = (index, value) => {
    const newEVs = [...evs]
    newEVs[index] = value
    setEVs(newEVs)
  }

  const handleShinyChange = (e) => {
    setIsShiny(e.target.checked)
  }

  return (
    <div>
      {/* Image */}
      <img src={''} alt="Pokemon" />

      {/* Selector for choosing Pokemon */}
      <select value={selectedPokemon} onChange={handlePokemonChange}>
        <option value="">Select pokemon</option>
        {pokemonList.map((pokemon) => (
          <option key={pokemon.id} value={pokemon.name}>
            {pokemon.name}
          </option>
        ))}
      </select>

      {/* Nickname input */}
      <label>
        Nickname:
        <input type="text" value={nickname} onChange={(e) => setNickname(e.target.value)} />
      </label>

      {/* Labels to show Pokemon types */}

      {/* Selector for choosing ability */}
      <select value={selectedAbility} onChange={handleAbilityChange}>
        <option value="">Select ability</option>
        {abilityList.map((ability) => (
          <option key={ability.id} value={ability.name}>
            {ability.name}
          </option>
        ))}
      </select>

      {/* Selector for choosing nature */}
      <select value={selectedNature} onChange={handleNatureChange}>
        <option value="">Select nature</option>
        {natureList.map((nature) => (
          <option key={nature.id} value={nature.name}>
            {nature.name}
          </option>
        ))}
      </select>

      {/* Selector for choosing item */}
      <select value={selectedItem} onChange={handleItemChange}>
        <option value="">Select item</option>
        {itemList.map((item) => (
          <option key={item.id} value={item.name}>
            {item.name}
          </option>
        ))}
      </select>

      {/* Six sliders for IVs */}
      <div>
        <h3>IVs</h3>
        {ivs.map((value, index) => (
          <input
            key={index}
            type="range"
            min={0}
            max={31}
            value={value}
            onChange={(e) => handleIVChange(index, parseInt(e.target.value))}
          />
        ))}
      </div>

      {/* Six sliders for EVs */}
      <div>
        <h3>EVs</h3>
        {evs.map((value, index) => (
          <input
            key={index}
            type="range"
            min={0}
            max={255}
            value={value}
            onChange={(e) => handleEVChange(index, parseInt(e.target.value))}
          />
        ))}
      </div>

      <label>
        Shiny:
        <input type="checkbox" checked={isShiny} onChange={handleShinyChange} />
      </label>
    </div>
  )
}

export default PokemonForm