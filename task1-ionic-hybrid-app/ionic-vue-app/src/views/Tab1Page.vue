<template>
  <ion-page>
    <ion-header :translucent="true">
      <ion-toolbar>
        <ion-title>Pokédex</ion-title>
      </ion-toolbar>
    </ion-header>
    
    <ion-content :fullscreen="true" class="ion-padding">
      <ion-header collapse="condense">
        <ion-toolbar>
          <ion-title size="large">Pokédex</ion-title>
        </ion-toolbar>
      </ion-header>

      <div class="content-container">
        <!-- Hero Section -->
        <div class="hero-section">
          <h1 class="hero-title">Explorador Pokémon</h1>
          <p class="hero-subtitle">Descubre todos los Pokémon con navegación por páginas</p>
        </div>

        <!-- Pagination Info -->
        <div class="pagination-info" v-if="pokemon.length > 0">
          <ion-chip color="white" outline>
            <ion-label>Página {{ currentPage }} de {{ totalPages }}</ion-label>
          </ion-chip>
          <ion-chip color="white" outline>
            <ion-label>{{ totalPokemon }} Pokémon total</ion-label>
          </ion-chip>
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="loading-section">
          <ion-spinner name="dots" class="loading-spinner"></ion-spinner>
          <p>Cargando Pokémon de la página {{ currentPage }}...</p>
        </div>

        <!-- Error State -->
        <div v-if="error && !loading" class="error-section">
          <ion-card class="error-card">
            <ion-card-content>
              <div class="error-content">
                <ion-icon :icon="alertCircleOutline" class="error-icon"></ion-icon>
                <h3>Error al cargar</h3>
                <p>{{ error }}</p>
                <ion-button 
                  @click="loadPage(currentPage)" 
                  color="medium" 
                  fill="outline"
                  size="small"
                >
                  <ion-icon :icon="refreshOutline" slot="start"></ion-icon>
                  Reintentar
                </ion-button>
              </div>
            </ion-card-content>
          </ion-card>
        </div>

        <!-- Pokemon Grid -->
        <div v-if="pokemon.length > 0 && !loading" class="pokemon-section">
          <div class="pokemon-grid">
            <ion-card 
              v-for="(poke, index) in pokemon" 
              :key="poke.id" 
              class="pokemon-card"
              :style="{ 'animation-delay': `${index * 0.05}s` }"
            >
              <ion-card-content>
                <div class="pokemon-header">
                  <div class="pokemon-image">
                    <img 
                      :src="poke.sprites?.front_default || 'https://via.placeholder.com/80x80?text=?'" 
                      :alt="poke.name"
                      class="pokemon-sprite"
                    />
                  </div>
                  <div class="pokemon-number">
                    <ion-chip color="white" outline size="small">
                      <ion-label>#{{ String(poke.id).padStart(3, '0') }}</ion-label>
                    </ion-chip>
                  </div>
                </div>
                
                <div class="pokemon-info">
                  <h3 class="pokemon-name">{{ capitalizeFirst(poke.name) }}</h3>
                  
                  <div class="pokemon-types">
                    <ion-chip 
                      v-for="type in poke.types" 
                      :key="type.type.name"
                      :color="getTypeColor(type.type.name)"
                      size="small"
                      class="type-chip"
                    >
                      <ion-label>{{ translateType(type.type.name) }}</ion-label>
                    </ion-chip>
                  </div>

                  <div class="pokemon-stats">
                    <div class="stat-row">
                      <div class="stat-item">
                        <span class="stat-label">Altura</span>
                        <span class="stat-value">{{ (poke.height / 10).toFixed(1) }}m</span>
                      </div>
                      <div class="stat-item">
                        <span class="stat-label">Peso</span>
                        <span class="stat-value">{{ (poke.weight / 10).toFixed(1) }}kg</span>
                      </div>
                    </div>
                    <div class="stat-item experience">
                      <span class="stat-label">Experiencia</span>
                      <span class="stat-value">{{ poke.base_experience }}</span>
                    </div>
                  </div>

                  <div class="pokemon-abilities">
                    <div class="abilities-list">
                      <ion-chip 
                        v-for="ability in poke.abilities.slice(0, 2)" 
                        :key="ability.ability.name"
                        color="white"
                        outline
                        size="small"
                      >
                        <ion-label>{{ capitalizeFirst(ability.ability.name) }}</ion-label>
                      </ion-chip>
                    </div>
                  </div>
                </div>
              </ion-card-content>
            </ion-card>
          </div>

          <!-- Pagination Controls -->
          <div class="pagination-controls">


            <!-- Page Numbers -->
            <div class="page-numbers">
              <ion-button 
                v-for="page in visiblePages" 
                :key="page"
                :fill="page === currentPage ? 'solid' : 'outline'"
                :color="page === currentPage ? 'dark' : 'medium'"
                size="default"
                @click="loadPage(page)"
                :disabled="loading"
                class="page-button"
              >
                {{ page }}
              </ion-button>
            </div>
          </div>
        </div>

        <!-- Empty State -->
        <div v-if="pokemon.length === 0 && !loading && !error" class="empty-state">
          <div class="empty-content">
            <ion-icon :icon="gameControllerOutline" class="empty-icon"></ion-icon>
            <h3>¡Cargando tu aventura!</h3>
            <p>Preparando la primera página de Pokémon...</p>
          </div>
        </div>
      </div>
    </ion-content>
  </ion-page>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { 
  IonPage, 
  IonHeader, 
  IonToolbar, 
  IonTitle, 
  IonContent,
  IonCard,
  IonCardContent,
  IonButton,
  IonIcon,
  IonChip,
  IonLabel,
  IonSpinner
} from '@ionic/vue';
import { 
  gameControllerOutline,
  chevronBackOutline,
  chevronForwardOutline,
  refreshOutline,
  alertCircleOutline
} from 'ionicons/icons';
import axios from 'axios';

// Reactive data
const pokemon = ref<any[]>([]);
const loading = ref(false);
const error = ref('');
const currentPage = ref(1);
const pokemonPerPage = 20;
const totalPokemon = ref(1010); // Total aproximado de Pokémon

// Computed properties
const totalPages = computed(() => Math.ceil(totalPokemon.value / pokemonPerPage));

const visiblePages = computed(() => {
  const pages = [];
  const start = Math.max(1, currentPage.value - 2);
  const end = Math.min(totalPages.value, start + 4);
  
  for (let i = start; i <= end; i++) {
    pages.push(i);
  }
  
  return pages;
});

// Load specific page
const loadPage = async (page: number) => {
  try {
    loading.value = true;
    error.value = '';
    currentPage.value = page;
    
    const offset = (page - 1) * pokemonPerPage;
    
    // Fetch list of Pokemon for this page
    const response = await axios.get(`https://pokeapi.co/api/v2/pokemon?limit=${pokemonPerPage}&offset=${offset}`);
    const pokemonList = response.data.results;
    
    // Update total count from API response
    totalPokemon.value = response.data.count;
    
    // Fetch detailed data for each Pokemon
    const pokemonDetails = await Promise.all(
      pokemonList.map(async (poke: any) => {
        const detailResponse = await axios.get(poke.url);
        return detailResponse.data;
      })
    );
    
    pokemon.value = pokemonDetails;
    
    console.log(`Página ${page} cargada con ${pokemonDetails.length} Pokémon`);
  } catch (err) {
    error.value = 'Error al cargar los Pokémon. Verifica tu conexión a internet.';
    console.error('Error fetching Pokemon:', err);
  } finally {
    loading.value = false;
  }
};

// Navigation functions
const goToPreviousPage = () => {
  if (currentPage.value > 1) {
    loadPage(currentPage.value - 1);
  }
};

const goToNextPage = () => {
  if (currentPage.value < totalPages.value) {
    loadPage(currentPage.value + 1);
  }
};

// Helper function to capitalize first letter
const capitalizeFirst = (str: string): string => {
  return str.charAt(0).toUpperCase() + str.slice(1);
};

// Function to get type color
const getTypeColor = (type: string): string => {
  const typeColors: { [key: string]: string } = {
    fire: 'warning',
    water: 'primary',
    grass: 'success',
    electric: 'warning',
    psychic: 'medium',
    ice: 'light',
    dragon: 'medium',
    dark: 'dark',
    fairy: 'light',
    fighting: 'medium',
    poison: 'medium',
    ground: 'warning',
    flying: 'light',
    bug: 'success',
    rock: 'medium',
    ghost: 'medium',
    steel: 'medium',
    normal: 'light'
  };
  return typeColors[type] || 'light';
};

// Function to translate Pokemon types to Spanish
const translateType = (type: string): string => {
  const typeTranslations: { [key: string]: string } = {
    fire: 'Fuego',
    water: 'Agua',
    grass: 'Hierba',
    electric: 'Eléctrico',
    psychic: 'Psíquico',
    ice: 'Hielo',
    dragon: 'Dragón',
    dark: 'Siniestro',
    fairy: 'Hada',
    fighting: 'Lucha',
    poison: 'Veneno',
    ground: 'Tierra',
    flying: 'Volador',
    bug: 'Bicho',
    rock: 'Roca',
    ghost: 'Fantasma',
    steel: 'Acero',
    normal: 'Normal'
  };
  return typeTranslations[type] || capitalizeFirst(type);
};

// Auto-load first page when component mounts
onMounted(() => {
  loadPage(1);
});
</script>

<style scoped>
.content-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 16px;
}

/* Hero Section */
.hero-section {
  text-align: center;
  padding: 40px 24px;
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
  border-radius: 16px;
  margin-bottom: 32px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
  border: 1px solid rgba(226, 232, 240, 0.6);
}

.hero-title {
  font-size: 32px;
  font-weight: 700;
  color: #374151;
  margin: 0 0 12px 0;
  letter-spacing: -0.025em;
}

.hero-subtitle {
  font-size: 18px;
  color: #6b7280;
  margin: 0;
  line-height: 1.4;
  font-weight: 400;
}

/* Pagination Info */
.pagination-info {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-bottom: 24px;
  flex-wrap: wrap;
}

/* Loading */
.loading-section {
  text-align: center;
  padding: 60px 20px;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  color: #9ca3af;
  margin-bottom: 20px;
}

.loading-section p {
  color: #6b7280;
  font-size: 18px;
  font-weight: 400;
}

/* Error */
.error-section {
  margin: 24px 0;
}

.error-card {
  border: 1px solid #fecaca;
  background: #fef2f2;
}

.error-content {
  text-align: center;
  padding: 24px;
}

.error-icon {
  font-size: 40px;
  color: #ef4444;
  margin-bottom: 16px;
}

.error-content h3 {
  color: #dc2626;
  margin: 0 0 12px 0;
  font-size: 20px;
  font-weight: 600;
}

.error-content p {
  color: #991b1b;
  margin: 0 0 20px 0;
  font-size: 16px;
}

/* Pokemon Grid */
.pokemon-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 40px;
}

.pokemon-card {
  animation: slideInUp 0.5s ease-out both;
  transition: all 0.3s ease;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  border: 1px solid #e5e7eb;
  background: white;
}

.pokemon-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12);
  border-color: #d1d5db;
}

@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.pokemon-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.pokemon-image {
  width: 90px;
  height: 90px;
  background: linear-gradient(135deg, #f9fafb, #f3f4f6);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border: 2px solid #f9fafb;
}

.pokemon-sprite {
  width: 70px;
  height: 70px;
  object-fit: contain;
}

.pokemon-info {
  text-align: center;
}

.pokemon-name {
  font-size: 22px;
  font-weight: 600;
  margin: 0 0 12px 0;
  color: #374151;
  text-transform: capitalize;
  letter-spacing: -0.025em;
}

.pokemon-types {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}

.type-chip {
  font-weight: 500;
  text-transform: uppercase;
  font-size: 11px;
  letter-spacing: 0.5px;
}

.pokemon-stats {
  background: #f9fafb;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
  border: 1px solid #f3f4f6;
}

.stat-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 12px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.stat-item.experience {
  grid-column: 1 / -1;
}

.stat-label {
  font-size: 12px;
  font-weight: 500;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.8px;
}

.stat-value {
  font-size: 16px;
  font-weight: 600;
  color: #374151;
}

.abilities-list {
  display: flex;
  justify-content: center;
  gap: 6px;
  flex-wrap: wrap;
}

/* Pagination Controls */
.pagination-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
  margin: 40px 0;
  flex-wrap: wrap;
}

.nav-button {
  font-weight: 500;
  min-width: 120px;
  --border-color: #d1d5db;
  --color: #6b7280;
}

.nav-button:hover {
  --background: #f9fafb;
}

.page-numbers {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.page-button {
  min-width: 48px;
  font-weight: 500;
  --border-color: #d1d5db;
}

.page-button[color="dark"] {
  --background: #374151;
  --color: white;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 80px 20px;
}

.empty-icon {
  font-size: 80px;
  color: #d1d5db;
  margin-bottom: 24px;
  opacity: 0.8;
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 0.8; }
  50% { opacity: 0.5; }
}

.empty-content h3 {
  font-size: 24px;
  color: #374151;
  margin: 0 0 12px 0;
  font-weight: 600;
}

.empty-content p {
  color: #6b7280;
  font-size: 18px;
  max-width: 400px;
  margin: 0 auto;
  line-height: 1.5;
}

/* Responsive Design */
@media (max-width: 768px) {
  .content-container {
    padding: 0 12px;
  }
  
  .hero-title {
    font-size: 28px;
  }
  
  .hero-subtitle {
    font-size: 16px;
  }
  
  .pokemon-grid {
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: 16px;
  }
  
  .pagination-controls {
    flex-direction: column;
    gap: 12px;
  }
  
  .page-numbers {
    order: -1;
  }
  
  .nav-button {
    min-width: 100px;
  }
  
  .pagination-info {
    flex-direction: column;
    align-items: center;
    gap: 8px;
  }
  
  .stat-row {
    grid-template-columns: 1fr;
    gap: 8px;
  }
}

@media (max-width: 480px) {
  .hero-section {
    padding: 32px 16px;
  }
  
  .pokemon-grid {
    grid-template-columns: 1fr;
  }
  
  .page-numbers {
    justify-content: center;
  }
  
  .page-button {
    min-width: 40px;
  }
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  .hero-section {
    background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
    border-color: #374151;
  }
  
  .hero-title {
    color: #f9fafb;
  }
  
  .hero-subtitle {
    color: #d1d5db;
  }
  
  .pokemon-card {
    background: #1f2937;
    border-color: #374151;
  }
  
  .pokemon-image {
    background: linear-gradient(135deg, #374151, #1f2937);
    border-color: #374151;
  }
  
  .pokemon-name {
    color: #f9fafb;
  }
  
  .pokemon-stats {
    background: #374151;
    border-color: #4b5563;
  }
  
  .stat-value {
    color: #f9fafb;
  }
  
  .error-card {
    background: #1f2937;
    border-color: #ef4444;
  }
}
</style>
