# Panduan Penggunaan Routing/Navigasi

## Navigasi tanpa mengirim data (tanpa parameter)
    - menumpuk halaman baru keatas halaman lama (push), bisa tekan tombol back
    - gunakan untuk pindah ke halaman beranda & pencarian
    - menggunakan Get.toNamed
    - contoh:
        ElevatedButton(
            child: Text("back to home"),
            onPressed: () {
                Get.toNamed(AppRoutes.BERANDA);
            },
            );
    
## Navigasi dengan mengirim data (dengan parameter)
    - menumpuk halaman baru keatas halaman lama (push), bisa tekan tombol back
    - gunakan untuk pindah ke halaman beranda & pencarian
    - gunakan saat pindah ke halaman detail event
    - rute didefinisikan sebagai static const LIHAT_TIKET = '/lihat_tiket/:id';
    - ganti bagian id dengan id dari event
    - contoh:
        final event = controller.recommendedEvents[index]; // misal event mewakili event yg ditampilkan di card

        Card(
            child: ListTile(
                title: Text(event.name),
                subtitle: Text(event.city),
                onTap: () {
                
                Get.toNamed(
                    AppRoutes.LIHAT_TIKET.replaceAll(':id', event.id)
                );
                },
            ),
            )
